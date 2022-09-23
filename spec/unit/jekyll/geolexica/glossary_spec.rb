# (c) Copyright 2020 Ribose Inc.
#

RSpec.describe ::Jekyll::Geolexica::Glossary do
  subject { instance }

  let(:instance) { described_class.new(fake_site) }
  let(:fake_site) { instance_double(Jekyll::Site, config: fake_config) }
  let(:fake_config) { {} }

  it { is_expected.to respond_to(:each_concept) }
  it { is_expected.to respond_to(:each_termid) }

  describe "#language_statistics" do
    subject { instance.method(:language_statistics) }

    let(:fake_config) do
      {"geolexica" => { "term_languages" => %w[eng deu pol] }}
    end

    before do
      add_concepts(
        {"termid" => 1, "eng" => {}},
        {"termid" => 2, "eng" => {}, "pol" => {}, },
        {"termid" => 3, "eng" => {}, "deu" => {}, },
        {"termid" => 4, "eng" => {}, "deu" => {}, },
      )
    end

    it "returns a hash with languages as keys and natural numbers as values" do
      retval = subject.call
      expect(retval).to be_kind_of(Hash)
      expect(retval.keys).to all be_kind_of(String) & have_attributes(size: 3)
      expect(retval.values).to all be_kind_of(Integer) & (be >= 0)
      expect(retval).to eq({"eng" => 4, "deu" => 2, "pol" => 1})
    end
  end

  def add_concepts(*concept_hashes)
    concepts = concept_hashes.map { |h| described_class::Concept.new(h) }
    concepts.each { |c| instance.store c }
  end
end
