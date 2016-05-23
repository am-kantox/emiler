#
#                            Fuzzy String Match
#
#   Copyright 2010-2011 Kiyoka Nishiyama
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
module FuzzyStringMatch
  class JaroWinklerPure
    THRESHOLD = 0.7

    def pure?
      true
    end

    def getDistance(s1, s2)
      a1 = s1.split(//)
      a2 = s2.split(//)

      max, min = s1.size > s2.size ? [a1, a2] : [a2, a1]

      range = [(max.size / 2 - 1), 0].max
      indexes = Array.new(min.size, -1)
      flags   = Array.new(max.size, false)

      matches = 0
      (0...min.size).each do |mi|
        c1 = min[mi]
        xi = [mi - range, 0].max
        xn = [mi + range + 1, max.size].min

        (xi...xn).each do |i|
          next unless !flags[i] && c1 == max[i]

          indexes[mi] = i
          flags[i] = true
          matches += 1
          break
        end
      end

      ms1 = Array.new(matches, nil)
      ms2 = Array.new(matches, nil)

      si = 0
      (0...min.size).each do |i|
        if indexes[i] != -1
          ms1[si] = min[i]
          si += 1
        end
      end

      si = 0
      (0...max.size).each do |i|
        if flags[i]
          ms2[si] = max[i]
          si += 1
        end
      end

      transpositions = 0
      (0...ms1.size).each do |mi|
        transpositions += 1 if ms1[mi] != ms2[mi]
      end

      prefix = 0
      (0...min.size).each do |mi|
        prefix += 1 if s1[mi] == s2[mi]
        break unless s1[mi] == s2[mi]
      end

      if 0 == matches
        0.0
      else
        m = matches.to_f
        t = (transpositions / 2)
        j = ((m / s1.size) + (m / s2.size) + ((m - t) / m)) / 3.0
        return j < THRESHOLD ? j : j + [0.1, 1.0 / max.size].min * prefix * (1 - j)
      end
    end
  end
end
