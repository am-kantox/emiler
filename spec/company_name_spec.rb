require 'spec_helper'

describe Emiler do
  describe '#similarity_company_name' do
    let!(:exact) { { jw: 1.0, full: 1.0, distances: [1.0, 1.0], matches: 2, result: true } }

    let!(:same) { Emiler.similarity('HOLLYWOOD LTD', 'HOLLYWOOD LTD', type: :company_name) }
    let!(:same_no_case) { Emiler.similarity('HOLLYWOOD LTD', 'Hollywood LTD', type: :company_name) }
    let!(:same_no_stopword) { Emiler.similarity('HOLLYWOOD LTD', 'Hollywood GmbH', type: :company_name) }
    let!(:example1) { Emiler.similarity('HOLLYWOOD pictures LTD', 'HOLLYWOOD', type: :company_name) }
    let!(:example2) { Emiler.similarity('HOLLYWOOD pictures LTD', 'Columbia Pictures', type: :company_name) }
    let!(:example3) { Emiler.similarity('HOLLYWOOD pictures LTD', 'Holyshit pict', type: :company_name) }
    let!(:nothing_similar) { Emiler.similarity('HOLLYWOOD LTD', 'Columbia Pictures', type: :company_name) }

    it 'prints inputs' do
      puts '—' * 60
      puts "same:                      #{same.inspect}"
      puts "same no case:              #{same_no_case.inspect}"
      puts "same name:                 #{same_no_stopword.inspect}"
      puts "example1:                  #{example1.inspect}"
      puts "example2:                  #{example2.inspect}"
      puts "example3:                  #{example3.inspect}"
      puts "nothing similar:           #{nothing_similar.inspect}"
      puts '—' * 60
    end

    it 'returns exact match for same company names' do
      expect(same).to eq(exact)
      expect(same_no_case).to eq(exact)
    end

    it 'returns name match for same names and different entities' do
      expect(same_no_stopword[:name]).to eq(1)
      expect(same_no_stopword[:full]).to eq(0.9)
    end

    it 'returns reasonable results for examples' do
      expect(example1[:full]).to be >= 0.8
      expect(example1[:matches]).to eq 1
      expect(example2[:full]).to be >= 0.6
      expect(example2[:full]).to be <= 0.8
      expect(example2[:matches]).to eq 1
      expect(example3[:full]).to be >= 0.6
      expect(example3[:full]).to be <= 0.8
      expect(example3[:matches]).to be_zero
    end

    it 'returns no match for different things' do
      expect(nothing_similar[:result]).to be_falsey
    end
  end
end
