# (c) Copyright 2020 Ribose Inc.
#

RSpec.describe ::Jekyll::Geolexica::ConceptSerializer do
  before(:each) do
    allow_any_instance_of(::Jekyll::Geolexica::Glossary).to receive(:glossary_path).and_return(fixture_path("v2_glossary"))
  end

  let(:fake_site) do
    instance_double(
      Jekyll::Site,
      config: fake_config,
    )
  end

  let(:fake_config) do
    YAML.safe_load(<<~YAML, permitted_classes: [Time])
      geolexica:
        term_languages:
          - eng
          - jpn
          - pol
          - unknown
    YAML
  end

  let(:concept_699) do
    glossary = ::Jekyll::Geolexica::Glossary.new(fake_site)
    glossary.send(:load_glossary)
    glossary["699"]
  end
  let(:serializer_10) { described_class.new(concept_699, fake_site) }

  it "initializes with a concept and site" do
    instance = described_class.new(concept_699, fake_site)
    expect(instance).to be_kind_of(described_class)
    expect(instance.termid).to eq(concept_699.termid)
    expect(instance.data).to eq(concept_699.data)
    expect(instance.site).to be(fake_site)
  end

  describe "#to_json" do
    subject { described_class.instance_method(:to_json) }

    it "returns a JSON in expected format" do
      retval = subject.bind(serializer_10).call
      expect(retval).to be_kind_of(String) & start_with("{")
      expect { JSON.parse(retval) }.not_to raise_error # be valid JSON

      parsed_expectation = JSON.parse fixture("concept-699.json")
      parsed_retval = JSON.parse retval

      expect(parsed_retval.keys).to contain_exactly(
        "term", "termid", "eng", "jpn", "pol", "unknown"
      )
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

      parsed_retval = YAML.safe_load retval, permitted_classes: [Time]

      expect(parsed_retval.keys).to contain_exactly(
        "term", "termid", "eng", "jpn", "pol", "unknown"
      )
      expect(parsed_retval["term"]).to eq(concept_699.data["term"])
      expect(parsed_retval["termid"]).to eq(concept_699.data["termid"])
      expect(parsed_retval["eng"]).to eq(concept_699.data["eng"])
      expect(parsed_retval.fetch("unknown", :missing)).to be_nil
    end
  end
end
