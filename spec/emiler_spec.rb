require 'spec_helper'

describe Emiler do
  it 'has a version number' do
    expect(Emiler::VERSION).not_to be nil
  end

  describe '#similarity' do
    let!(:exact) { { jw: 1, full: 1, name: 1, domain: 1, result: true } }

    let!(:same) { Emiler.similarity('a@example.com', 'a@example.com') }
    let!(:same_no_case) { Emiler.similarity('a@example.com', 'A@eXamPle.cOM') }
    let!(:same_domain) { Emiler.similarity('abcdefgh@example.com', 'stuvwxyz@example.com') }
    let!(:same_domain_2nd_level) { Emiler.similarity('abcdefgh@example.com', 'abcdefgh@example.ru') }
    let!(:same_name) { Emiler.similarity('abcdefgh@example.com', 'abcdefgh@zzzzzz.zz') }
    let!(:similar_name_same_domain) { Emiler.similarity('abcdefgh.zzzzzz@example.com', 'abcdefgh@example.com') }
    let!(:similar_name_other_domain) { Emiler.similarity('zzzzzz_abcdefgh@example.com', 'abcdefgh@zzzzzz.zz') }
    let!(:nothing_similar) { Emiler.similarity('zzzzzzabcdefgh@example.com', 'abcdefgh@zzzzzz.zz') }

    it 'prints inputs' do
      puts '—' * 60
      puts "same:                      #{same.inspect}"
      puts "same no case:              #{same_no_case.inspect}"
      puts "same domain:               #{same_domain.inspect}"
      puts "same 2nd level domain:     #{same_domain_2nd_level.inspect}"
      puts "same name:                 #{same_name.inspect}"
      puts "similar name same domain:  #{similar_name_same_domain.inspect}"
      puts "similar name other domain: #{similar_name_other_domain.inspect}"
      puts "nothing similar:           #{nothing_similar.inspect}"
      puts '—' * 60
    end

    it 'returns exact match for same emails' do
      expect(same).to eq(exact)
      expect(same_no_case).to eq(exact)
    end

    it 'returns domain match for same domains' do
      expect(same_domain[:domain]).to eq(1)
    end

    it 'returns name match for same names' do
      expect(same_name[:name]).to eq(1)
    end

    it 'returns kinda match for same domains in different 1st-level zones' do
      expect(same_name[:full]).to be < same_domain_2nd_level[:full]
    end

    it 'returns kinda match for same domains and similar names' do
      expect(similar_name_same_domain[:full]).to be > similar_name_other_domain[:full]
    end

    it 'returns no match for different things' do
      expect(nothing_similar[:full]).to be < 0.4
    end

    it 'returns null for malformed emails' do
      expect(Emiler.similarity('example.com', 'abcdefgh@zzzzzz.zz')[:full]).to eq(0)
      expect(Emiler.similarity('', 'abcdefgh@zzzzzz.zz')[:full]).to eq(0)
      expect(Emiler.similarity(5, 'abcdefgh@zzzzzz.zz')[:full]).to eq(0)
      expect(Emiler.similarity(nil, 'abcdefgh@zzzzzz.zz')[:full]).to eq(0)
    end
  end
end
