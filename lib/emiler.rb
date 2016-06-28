require 'emiler/version'
require 'emiler/jarowinkler'

require 'phone'

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

    # stub for unknown types; returns empty hash for `similarity` to return jaro-winkler distance only
    def similarity_default(*)
      { result: nil }
    end

    # similarity for company names
    def similarity_company_name c1, c2
      return { full: 1.0,
               distances: [1.0] * c1.split(/\s+/).size,
               matches: c1.split(/\s+/).size,
               result: true } if c1 == c2 # exact match

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

    # similarity for phone numbers
    def similarity_phone p1, p2
      return { full: 1.0,
               distances: [1.0],
               result: true } if p1 == p2 # exact match

      p1, p2 = [p1, p2].map { |p| p.split(/[,;]/) }
                       .map do |p|
                         p.map do |e|
                           phone = e.delete('^0-9')
                           phone = case phone.length
                                   when 0..6 then phone
                                   when 7 then "+3493#{phone}" # consider Barcelona
                                   when 8..9 then "+34#{phone}" # consider Spain
                                   else "+#{phone}"
                                   end
                           # rubocop:disable Style/RescueModifier
                           Phoner::Phone.parse(phone) rescue nil # Phoner::CountryCodeError
                           # rubocop:enable Style/RescueModifier
                         end.compact
                       end

      dists = p1.product(p2)
                .reject do |(pp1, pp2)|
                  pp1.country_code != pp2.country_code ||
                    pp1.area_code != pp2.area_code ||
                    pp1.number[0...-2] != pp2.number[0...-2]
                end.map do |(pp1, pp2)|
                  case
                  when pp1.number[-2..-1] == pp2.number[-2..-1] then 1.0
                  when pp1.number[-2] == pp2.number[-2] then 0.9
                  else 0.8
                  end
                end.sort.reverse

      { full: dists.first || 0.0, distances: dists, result: dists.first && dists.first >= INEXACT_MATCH_COEFFICIENT }
    end

    # rubocop:disable Metrics/AbcSize
    # similarity for emails
    def similarity_email e1, e2
      return { full: 1.0,
               name: 1.0,
               domain: 1.0,
               result: true } if e1 == e2

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
