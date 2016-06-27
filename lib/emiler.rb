require 'emiler/version'
require 'emiler/jarowinkler'

module Emiler
  INEXACT_MATCH_COEFFICIENT = ENV['INEXACT_MATCH_COEFFICIENT'] || 0.8
  RAISE_ON_MALFORMED_EMAIL = ENV['RAISE_ON_MALFORMED_EMAIL']
  COMPANY_NAME_STOP_WORDS = %w(ltd gmbh inc).freeze

  class JW
    attr_reader :jw
    def initialize
      @jw = FuzzyStringMatch::JaroWinklerPure.new
    end

    def distance s1, s2
      @jw.get_distance s1, s2
    end

    MATCHER = JW.new
    DUMMY = { jw: 0, full: 0, name: 0, domain: 0, result: false }.freeze

    private :initialize
  end

  class MalformedEmailError < StandardError
    def initialize e1, e2
      super "Rejected to calculate distance for malformed emails <#{e1}>, <#{e2}> due to RAISE_ON_MALFORMED_EMAIL setting"
    end
  end

  class << self
    def similarity item1, item2, type: :email
      type = :default unless private_methods.include? :"similarity_#{type}"
      item1, item2 = [item1, item2].map(&:to_s).map(&:strip).map(&:downcase)
      { jw: JW::MATCHER.distance(item1, item2) }.merge send(:"similarity_#{type}", item1, item2)
    end

    private

    # similarity for company names
    def similarity_company_name c1, c2
      return { full: 1.0, result: true } if c1 == c2 # exact match

      c1, c2 = [c1, c2].map { |c| c.split(/\s+/).reject(&COMPANY_NAME_STOP_WORDS.method(:include?)) }
      return { full: 1.0 - (1.0 - INEXACT_MATCH_COEFFICIENT) / 2.0, name: 1.0, result: true } if c1 == c2 # match without stopwords

      dists = c1.product(c2)
                .map { |(w1, w2)| JW::MATCHER.distance(w1, w2) }
                .sort
                .reverse
      count = [c1, c2].map(&:size).min
      average = dists.take(count).map.with_index { |e, i| e * (1.0 - i.to_f / count) / count }.reduce(:+)
      { full: average, distances: dists, matches: dists.count(1.0), result: false }
    end

    # stub for unknown types; returns empty hash for `similarity` to return jaro-winkler distance only
    def similarity_default(*)
      {}
    end

    # rubocop:disable Metrics/AbcSize
    # similarity for emails
    def similarity_email e1, e2
      em1, em2 = [e1, e2].map { |e| e.split '@' }
      if em1.size != 2 || em2.size != 2
        raise MalformedEmailError.new(e1, e2) if RAISE_ON_MALFORMED_EMAIL
        return JW::DUMMY
      end

      domain = case
               when em1.last == em2.last then 1 # exact domain match
               when [em1, em2].map { |e| e.last.split('.')[-2] }.reduce(:==) then INEXACT_MATCH_COEFFICIENT
               else INEXACT_MATCH_COEFFICIENT / 2.0 * JW::MATCHER.distance(em1.last, em2.last)
               end
      name =   case
               when em1.first == em2.first then 1 # exact match
               when ![em1, em2].map { |e| e.first.scan(/[a-z]+/) }.reduce(:&).empty? then INEXACT_MATCH_COEFFICIENT
               else INEXACT_MATCH_COEFFICIENT / 2.0 * JW::MATCHER.distance(em1.first, em2.first)
               end
      full = domain * (1.0 - INEXACT_MATCH_COEFFICIENT) + name * INEXACT_MATCH_COEFFICIENT
      { full: full, name: name, domain: domain, result: full >= INEXACT_MATCH_COEFFICIENT * INEXACT_MATCH_COEFFICIENT }
    end
    # rubocop:enable Metrics/AbcSize
  end

  private_constant :JW
end
