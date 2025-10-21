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
      { "geolexica" => { "term_languages" => %w[eng deu pol] } }
    end

    before do
      add_concepts(
        { "termid" => 1, "eng" => {} },
        { "termid" => 2, "eng" => {}, "pol" => {} },
        { "termid" => 3, "eng" => {}, "deu" => {} },
        { "termid" => 4, "eng" => {}, "deu" => {} },
      )
    end

    it "returns a hash with languages as keys and natural numbers as values" do
      retval = subject.call
      expect(retval).to be_kind_of(Hash)
      expect(retval.keys).to all be_kind_of(String) & have_attributes(size: 3)
      expect(retval.values).to all be_kind_of(Integer) & (be >= 0)
      expect(retval).to eq({ "eng" => 4, "deu" => 2, "pol" => 1 })
    end
  end

  context "Glossarist V2 concepts" do
    describe "#load_glossary" do
      let(:load_glossary) { subject.send(:load_glossary) }

      let(:expected_data) do
        {
          "id" => "055c7785-e3c2-4df0-bcbc-83c1314864af",
          "term" => "association <UML>",
          "termid" => "SPP",
          "status" => "valid",
          "data" => {
            "identifier" => "SPP",
            "localized_concepts" => {
              "eng" => "04e539b2-4557-4d05-a603-9881ed6951c6",
            },
          },
          "eng" => {
            "dates" => [{ "date" => "2005-07-15T00:00:00+05:00", "type" => "accepted" },
                        { "date" => "2015-07-01T00:00:00+05:00",
                          "type" => "amended" }], "definition" => [{ "content" => "semantic relationship between two or more classifiers that specifies connections among their instances" }], "entry_status" => "superseded", "examples" => [{ "content" => "0" }], "id" => "17", "language_code" => "eng", "notes" => [{ "content" => "A binary association is an association among exactly two classifiers (including the possibility of an association from a classifier to itself)." }], "release" => "-1", "review_date" => "2009-08-31T00:00:00+06:00", "review_decision_date" => "2015-07-01T00:00:00+05:00", "review_decision_event" => "Publication of ISO 19150-2:2015(E)", "sources" => [{ "origin" => { "link" => "https://www.iso.org/standard/32620.html", "ref" => "ISO/IEC 19501" }, "status" => "restyle", "type" => "authoritative" }, { "origin" => { "ref" => "ISO/TS 19103:2005 ,4.2.3" }, "status" => "identical", "type" => "lineage" }], "status" => "superseded", "terms" => [{ "designation" => "association <UML>", "type" => "expression" }]
          },
        }
      end

      before(:each) do
        allow(subject).to receive(:glossary_path).and_return(fixture_path("paneron_glossary"))
        allow(subject).to receive(:concepts_glob).and_return(fixture_path("paneron_glossary/concept/*"))
        allow(subject).to receive(:localized_concepts_path).and_return(fixture_path("paneron_glossary/localized_concept"))
      end

      it "should change data count" do
        expect { load_glossary }.to change { subject.count }.from(0).to(1)
      end

      it "should load data" do
        load_glossary
        expect(subject["SPP"].data).to include(expected_data)
      end
    end
  end

  context "Glossarist V2 concepts" do
    describe "#load_glossary" do
      let(:load_glossary) { subject.send(:load_glossary) }

      before(:each) do
        allow(subject).to receive(:glossary_path).and_return(fixture_path("v2_glossary"))
      end

      let(:localized_concepts) do
        { "eng" => "f97c8700-4637-5d81-875d-4db604cf319b", "ara" => "48aee9d4-b7ce-5aac-b00f-d4170673471b",
          "kor" => "fc3e9fa0-a65f-593e-bcd5-a63469d9fa95", "rus" => "4b726987-275c-5110-b42b-8fbbf0239d9f", "spa" => "e800bb84-7e77-56fe-9963-1d049e8553b1" }
      end

      let(:eng_concept) do
        { "dates" => [{ "date" => "2007-09-01T00:00:00+05:00", "type" => "accepted" }],
          "definition" => [{ "content" => "application schema written in UML in accordance with ISO 19109" }], "entry_status" => "valid", "examples" => [], "id" => "699", "language_code" => "eng", "notes" => [], "release" => "1.0", "review_date" => "2020-01-09T00:00:00+05:00", "review_decision_date" => "2020-01-09T00:00:00+05:00", "review_decision_event" => "Publication of ISO 19136-1:2020(E)", "sources" => [{ "origin" => { "locality" => { "reference_from" => "3.1.61", "type" => "clause" }, "link" => "https://www.iso.org/standard/75676.html", "ref" => "ISO 19136-1:2020" }, "type" => "authoritative" }, { "origin" => { "ref" => "ISO 19136:2007" }, "status" => "unspecified", "type" => "lineage" }], "status" => "valid", "terms" => [{ "designation" => "UML application schema", "normative_status" => "preferred", "type" => "expression" }] }
      end

      let(:ara_concept) do
        { "dates" => [{ "date" => "2007-09-01T00:00:00+05:00", "type" => "accepted" }],
          "definition" => [{ "content" => "مخطط تطبيقي مكتوب بلغة UML وفقا لمواصفة آيزو القياسية 19109" }], "entry_status" => "valid", "examples" => [], "id" => "699", "language_code" => "ara", "notes" => [], "release" => "1.0", "review_date" => "2020-01-09T00:00:00+05:00", "review_decision_date" => "2020-01-09T00:00:00+05:00", "review_decision_event" => "Publication of ISO 19136-1:2020(E)", "sources" => [{ "origin" => { "locality" => { "reference_from" => "3.1.61", "type" => "clause" }, "link" => "https://www.iso.org/standard/75676.html", "ref" => "ISO 19136-1:2020" }, "type" => "authoritative" }, { "origin" => { "ref" => "ISO 19136:2007" }, "status" => "unspecified", "type" => "lineage" }], "status" => "valid", "terms" => [{ "designation" => "مخطط تطبيق UML", "normative_status" => "preferred", "type" => "expression" }] }
      end

      let(:kor_concept) do
        { "dates" => [{ "date" => "2007-09-01T00:00:00+05:00", "type" => "accepted" }],
          "definition" => [{ "content" => "KS X ISO 19109에 따라 UML로 기술된 응용 스키마" }], "entry_status" => "valid", "examples" => [], "id" => "699", "language_code" => "kor", "notes" => [], "release" => "1.0", "review_date" => "2020-01-09T00:00:00+05:00", "review_decision_date" => "2020-01-09T00:00:00+05:00", "review_decision_event" => "Publication of ISO 19136-1:2020(E)", "sources" => [{ "origin" => { "locality" => { "reference_from" => "3.1.61", "type" => "clause" }, "link" => "https://www.iso.org/standard/75676.html", "ref" => "ISO 19136-1:2020" }, "type" => "authoritative" }, { "origin" => { "ref" => "ISO 19136:2007" }, "status" => "unspecified", "type" => "lineage" }], "status" => "valid", "terms" => [{ "designation" => "UML 응용 스키마", "normative_status" => "preferred", "type" => "expression" }] }
      end

      let(:rus_concept) do
        { "dates" => [{ "date" => "2007-09-01T00:00:00+05:00", "type" => "accepted" }],
          "definition" => [{ "content" => "схема приложения на UML, разработанная в соответствии с ISO 19109" }], "entry_status" => "valid", "examples" => [], "id" => "699", "language_code" => "rus", "notes" => [], "release" => "1.0", "review_date" => "2020-01-09T00:00:00+05:00", "review_decision_date" => "2020-01-09T00:00:00+05:00", "review_decision_event" => "Publication of ISO 19136-1:2020(E)", "sources" => [{ "origin" => { "locality" => { "reference_from" => "3.1.61", "type" => "clause" }, "link" => "https://www.iso.org/standard/75676.html", "ref" => "ISO 19136-1:2020" }, "type" => "authoritative" }, { "origin" => { "ref" => "ISO 19136:2007" }, "status" => "unspecified", "type" => "lineage" }], "status" => "valid", "terms" => [{ "designation" => "схема приложения UML", "normative_status" => "preferred", "type" => "expression" }] }
      end

      let(:spa_concept) do
        { "dates" => [{ "date" => "2007-09-01T00:00:00+05:00", "type" => "accepted" }],
          "definition" => [{ "content" => "esquema de aplicación escrito en UML de acuerdo  a ISO 19109" }], "entry_status" => "valid", "examples" => [], "id" => "699", "language_code" => "spa", "notes" => [], "release" => "1.0", "review_date" => "2020-01-09T00:00:00+05:00", "review_decision_date" => "2020-01-09T00:00:00+05:00", "review_decision_event" => "Publication of ISO 19136-1:2020(E)", "sources" => [{ "origin" => { "locality" => { "reference_from" => "3.1.61", "type" => "clause" }, "link" => "https://www.iso.org/standard/75676.html", "ref" => "ISO 19136-1:2020" }, "type" => "authoritative" }, { "origin" => { "ref" => "ISO 19136:2007" }, "status" => "unspecified", "type" => "lineage" }], "status" => "valid", "terms" => [{ "designation" => "esquema de aplicación UML", "normative_status" => "preferred", "type" => "expression" }] }
      end

      let(:expected_data) do
        {
          "id" => "00061441-c9f2-5dd8-b28b-20dd94ad5ebf",
          "term" => "UML application schema",
          "termid" => "699",
          "status" => "valid",
          "data" => {
            "identifier" => "699",
            "localized_concepts" => localized_concepts,
          },
          "eng" => eng_concept,
          "ara" => ara_concept,
          "kor" => kor_concept,
          "rus" => rus_concept,
          "spa" => spa_concept,
        }
      end

      it "should change data count" do
        expect { load_glossary }.to change { subject.count }.from(0).to(1)
      end

      it "should load data" do
        load_glossary
        expect(subject["699"].data).to include(expected_data)
      end
    end
  end

  def add_concepts(*concept_hashes)
    concepts = concept_hashes.map { |h| described_class::Concept.new(h) }
    concepts.each { |c| instance.store c }
  end
end
