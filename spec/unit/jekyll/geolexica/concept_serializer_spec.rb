# (c) Copyright 2020 Ribose Inc.
#

RSpec.describe ::Jekyll::Geolexica::ConceptSerializer do
  let(:concept_10) { load_concept_fixture("concept-10.yaml") }
  let(:serializer_10) { described_class.new(concept_10, fake_site) }

  let(:fake_site) do
    instance_double(
      Jekyll::Site,
      config: fake_config,
    )
  end

  let(:fake_config) do
    YAML.load(<<~YAML)
      geolexica:
        term_languages:
          - eng
          - jpn
          - pol
          - unknown
    YAML
  end

  it "initializes with a concept and site" do
    instance = described_class.new(concept_10, fake_site)
    expect(instance).to be_kind_of(described_class)
    expect(instance.termid).to eq(concept_10.termid)
    expect(instance.data).to eq(concept_10.data)
    expect(instance.site).to be(fake_site)
  end

  describe "#to_json" do
    subject { described_class.instance_method(:to_json) }

    it "returns a JSON in expected format" do
      retval = subject.bind(serializer_10).call
      expect(retval).to be_kind_of(String) & start_with("{")
      expect { JSON.parse(retval) }.not_to raise_error # be valid JSON

      parsed_expectation = JSON.parse fixture("concept-10.json")
      parsed_retval = JSON.parse retval

      expect(parsed_retval.keys).to contain_exactly(
        "term", "termid", "eng", "jpn", "pol", "unknown")
      expect(parsed_retval["term"]).to eq(parsed_expectation["term"])
      expect(parsed_retval["termid"]).to eq(parsed_expectation["termid"])
      expect(parsed_retval["eng"]).to eq(parsed_expectation["eng"])
      expect(parsed_retval["unknown"]).to be_nil
    end
  end

  describe "#to_yaml" do
    subject { described_class.instance_method(:to_yaml) }

    it "returns a YAML in expected format" do
      retval = subject.bind(serializer_10).call
      expect(retval).to be_kind_of(String) & start_with("---\n")
      expect { YAML.parse(retval) }.not_to raise_error # be valid YAML

      parsed_retval = YAML.load retval

      expect(parsed_retval.keys).to contain_exactly(
        "term", "termid", "eng", "jpn", "pol", "unknown")
      expect(parsed_retval["term"]).to eq(concept_10.data["term"])
      expect(parsed_retval["termid"]).to eq(concept_10.data["termid"])
      expect(parsed_retval["eng"]).to eq(concept_10.data["eng"])
      expect(parsed_retval.fetch("unknown", :missing)).to be_nil
    end
  end
end
