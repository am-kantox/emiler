require 'spec_helper'

describe Emiler do
  describe '#similarity_phone' do
    let!(:exact) { { jw: 1.0, full: 1.0, distances: [1.0], result: true } }

    let!(:same) { Emiler.similarity('+34 657 058 137', '+34 657 058 137', type: :phone) }
    let!(:same_no_case) { Emiler.similarity('+34 657 058 137', '+34657058137', type: :phone) }
    let!(:example1) { Emiler.similarity('+34 657 058 137', '+34 657 058 136', type: :phone) }
    let!(:example2) { Emiler.similarity('+34 657 058 137', '+34 657 058 150', type: :phone) }
    let!(:example3) { Emiler.similarity('+34 657 058 137', '+34 999 058 137', type: :phone) }
    let!(:example4) { Emiler.similarity('+34 657 058 137', '+1 657 058 137', type: :phone) }
    let!(:nothing_similar) { Emiler.similarity('+34 657 058 137', 'Columbia Pictures', type: :phone) }

    it 'prints inputs' do
      puts '—' * 60
      puts "same:                      #{same.inspect}"
      puts "same no case:              #{same_no_case.inspect}"
      puts "example1:                  #{example1.inspect}"
      puts "example2:                  #{example2.inspect}"
      puts "example3:                  #{example3.inspect}"
      puts "example4:                  #{example4.inspect}"
      puts "nothing similar:           #{nothing_similar.inspect}"
      puts '—' * 60
    end

    it 'returns exact match for same company names' do
      expect(same).to eq(exact)
      expect(same_no_case[:full]).to eq(1.0)
    end

    it 'returns reasonable results for examples' do
      expect(example1[:full]).to be >= 0.8
      expect(example2[:full]).to be >= 0.6
      expect(example3[:full]).to be <= 0.4
      expect(example4[:full]).to be <= 0.4
    end

    it 'returns no match for different things' do
      expect(nothing_similar[:result]).to be_falsey
    end
  end
end
