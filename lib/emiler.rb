require 'emiler/version'
require 'emiler/jarowinkler'

module Emiler
  INEXACT_MATCH_COEFFICIENT = ENV['INEXACT_MATCH_COEFFICIENT'] || 0.8
  RAISE_ON_MALFORMED_EMAIL = ENV['RAISE_ON_MALFORMED_EMAIL']

  class JW
    attr_reader :jw
    def initialize
      @jw = FuzzyStringMatch::JaroWinklerPure.new
    end

    def distance s1, s2
      @jw.getDistance s1, s2
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

  # rubocop:disable Metrics/AbcSize
  def similarity e1, e2
    e1, e2 = [e1, e2].map(&:to_s).map(&:downcase)
    em1, em2 = [e1, e2].map { |e| e.split '@' }

    if em1.size != 2 || em2.size != 2
      raise MalformedEmailError.new(e1, e2) if RAISE_ON_MALFORMED_EMAIL
      return JW::DUMMY
    end

    jw = JW::MATCHER.distance e1, e2

    domain = case
             when em1.last == em2.last then 1 # exact domain match
             when [em1, em2].map { |e| e.last.split('.')[-2] }.reduce(:==) then INEXACT_MATCH_COEFFICIENT
             else INEXACT_MATCH_COEFFICIENT / 2.0 * JW::MATCHER.distance(em1.last, em2.last)
             end

    name = case
           when em1.first == em2.first then 1 # exact match
           when ![em1, em2].map { |e| e.first.scan(/[a-z]+/) }.reduce(:&).empty? then INEXACT_MATCH_COEFFICIENT
           else INEXACT_MATCH_COEFFICIENT / 2.0 * JW::MATCHER.distance(em1.first, em2.first)
           end

    full = domain * 0.2 + name * 0.8

    { jw: jw, full: full, name: name, domain: domain, result: full >= 0.64 }
  end
  # rubocop:enable Metrics/AbcSize

  private_constant :JW, :MalformedEmailError
  module_function :similarity
end
