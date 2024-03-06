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

  context "Glossarist V2 concepts" do
    describe "#load_glossary" do
      let(:load_glossary) { subject.send(:load_glossary) }

      let(:expected_data) do
        {
          "id" => "055c7785-e3c2-4df0-bcbc-83c1314864af",
          "term" => "association <UML>",
          "termid" => "SPP",
          "data" => {
            "identifier" => "SPP",
            "localized_concepts" => {
              "eng" => "04e539b2-4557-4d05-a603-9881ed6951c6"
            }
          },
          "eng" => {
            "dates" => [
              {
                "date" => Time.parse("2005-07-15 00:00:00 +05:00"),
                "type" => "accepted"
              },
              {
                "date" => Time.parse("2015-07-01 00:00:00 +05:00"),
                "type" => "amended"
              }
            ],
            "definition" => [
              {
                "content" => "semantic relationship between two or more classifiers that specifies connections among their instances"
              }
            ],
            "examples" => [
              { "content" => "0" }
            ],
            "id" => "17",
            "notes" => [
              {
                "content" => "A binary association is an association among exactly two classifiers (including the possibility of an association from a classifier to itself)."
              }
            ],
            "release" => "-1",
            "sources" => [
              {
                "origin" => {
                  "link" => "https://www.iso.org/standard/32620.html"
                },
                "type" => "authoritative"
              }
            ],
            "terms" => [
              {
                "type" => "expression", "designation" => "association <UML>"
              }
            ],
            "language_code" => "eng",
            "entry_status" => "superseded",
            "review_date" => Time.parse("2009-08-31 00:00:00 +06:00"),
            "review_decision_date" => Time.parse("2015-07-01 00:00:00 +05:00"),
            "review_decision_event" => "Publication of ISO 19150-2:2015(E)",
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

  context "Glossarist V1 concepts" do
    describe "#load_glossary" do
      let(:load_glossary) { subject.send(:load_glossary) }

      before(:each) do
        allow(subject).to receive(:glossary_path).and_return(fixture_path("v1_glossary"))
      end

      let(:localized_concepts) do
        {
          "eng" => "1296fc23-5ab7-52c2-9219-09cc3b04b1e0",
          "ara" => "ea6a9deb-46b5-5f36-80d9-cbdc303d7d51",
          "dan" => "a0e49de6-2818-5b4a-9ca4-ce8d19993457",
          "ger" => "061ec573-6c10-5f70-8b01-062aa28161e4",
          "kor" => "436e863c-80d8-5a8b-ac25-e432fac10f5c",
          "rus" => "a2c61508-0c23-5c59-be68-efc09c7fe2eb",
          "spa" => "b70b2224-9a4f-5583-bd2b-736087c833b5",
          "swe" => "a8a854e0-e125-50bd-ac2a-1d95760eb0b5",
        }
      end

      let(:eng_concept) do
        {
          "dates" => [
            {
              "date" => Time.parse("2008-11-15 00:00:00 +08:00"),
              "type" => "accepted",
            },
          ],
          "definition" => [
            {
              "content" => "term rated according to the scale of the term acceptability rating as a synonym for a preferred term",
            },
          ],
          "examples" => [],
          "id" => "10",
          "lineage_source_similarity" => 1,
          "notes" => [],
          "release" => "2",
          "sources" => [
            {
              "origin" => {
                "ref" => "ISO 1087-1:2000",
                "clause" => "3.4.16, modified — the Note 1 to entry has been added.",
                "link" => "https://www.iso.org/standard/20057.html"
              },
              "type" => "authoritative",
            },
          ],
          "terms" => [
            {
              "type" => "expression",
              "normative_status" => "preferred",
              "designation" => "admitted term",
            },
          ],
          "language_code" => "eng",
          "entry_status" => "valid",
          "review_date" => Time.parse("2013-01-29 00:00:00 +08:00"),
          "review_decision_date" => Time.parse("2016-10-01 00:00:00 +08:00"),
          "review_decision_event" => "Publication of ISO 19104:2016",
        }
      end

      let(:ara_concept) do
        {
          "dates" => [
            {
              "date" => Time.parse("2008-11-15 00:00:00 +08:00"),
              "type" => "accepted",
            },
          ],
          "definition" => [
            {
              "content" => "مصطلح صنف وفقا لمقياس تصنيف قبول المصطلحات كمرادف للمصطلح المفضل"
            }
          ],
          "examples" => [],
          "id" => "10",
          "lineage_source_similarity" => 1,
          "notes" => [],
          "release" => "2",
          "sources" => [
            {
              "origin" => {
                "ref" => "ISO 1087-1:2000",
                "clause" => "3.4.16, modified — the Note 1 to entry has been added.",
                "link" => "https://www.iso.org/standard/20057.html",
              },
              "type" => "authoritative",
            }
          ],
          "terms" => [
            {
              "type" => "expression",
              "normative_status" => "preferred",
              "designation" => "مصطلح معترف به",
            },
          ],
          "language_code" => "ara",
          "entry_status" => "valid",
          "review_date" => Time.parse("2013-01-29 00:00:00 +08:00"),
          "review_decision_date" => Time.parse("2016-10-01 00:00:00 +08:00"),
          "review_decision_event" => "Publication of ISO 19104:2016",
        }
      end

      let(:dan_concept) do
        {
          "dates" => [
            {
              "date" => Time.parse("2008-11-15 00:00:00 +08:00"),
              "type" => "accepted",
            },
          ],
          "definition" => [
            {
              "content" => "term, klassificeret efter en skala for tilladte termer, anvendt som synonym for en foretrukket term",
            },
          ],
          "examples" => [],
          "id" => "10",
          "lineage_source_similarity" => 1,
          "notes" => [],
          "release" => "2",
          "sources" => [
            {
              "origin" => {
                "ref" => "ISO 1087-1:2000",
                "clause" => "3.4.16, modified — the Note 1 to entry has been added.",
                "link" => "https://www.iso.org/standard/20057.html",
              },
              "type" => "authoritative",
            },
          ],
          "terms" => [
            {
              "type" => "expression",
              "normative_status" => "preferred",
              "designation" => "tilladt term",
            },
          ],
          "language_code" => "dan",
          "entry_status" => "valid",
          "review_date" => Time.parse("2013-01-29 00:00:00 +08:00"),
          "review_decision_date" => Time.parse("2016-10-01 00:00:00 +08:00"),
          "review_decision_event" => "Publication of ISO 19104:2016",
        }
      end

      let(:ger_concept) do
        {
          "dates" => [
            {
              "date" => Time.parse("2008-11-15 00:00:00 +08:00"),
              "type" => "accepted",
            },
          ],
          "definition" => [],
          "examples" => [],
          "id" => "10",
          "lineage_source_similarity" => 1,
          "notes" => [],
          "release" => "2",
          "sources" => [
            {
              "origin" => {
                "ref" => "ISO 1087-1:2000",
                "clause" => "3.4.16, modified — the Note 1 to entry has been added.",
                "link" => "https://www.iso.org/standard/20057.html"
              },
              "type" => "authoritative",
            },
          ],
          "terms" => [
            {
              "type" => "expression",
              "normative_status" => "preferred",
              "designation" => "zugelassener Begriff",
            },
          ],
          "language_code" => "ger",
          "entry_status" => "valid",
          "review_date" => Time.parse("2013-01-29 00:00:00 +08:00"),
          "review_decision_date" => Time.parse("2016-10-01 00:00:00 +08:00"),
          "review_decision_event" => "Publication of ISO 19104:2016",
        }
      end

      let(:kor_concept) do
        {
          "dates" => [
            {
              "date" => Time.parse("2008-11-15 00:00:00 +08:00"),
              "type" => "accepted",
            },
          ],
          "definition" => [
            {
              "content" => "상용 용어의 동의어로써 용어 수용가능성 등급체계에 의거하여 등급이 부여된 용어",
            },
          ],
          "examples" => [],
          "id" => "10",
          "lineage_source_similarity" => 1,
          "notes" => [],
          "release" => "2",
          "sources" => [
            {
              "origin" => {
                "ref" => "ISO 1087-1:2000",
                "clause" => "3.4.16, modified — the Note 1 to entry has been added.",
                "link" => "https://www.iso.org/standard/20057.html",
              },
              "type" => "authoritative",
            },
          ],
          "terms" => [
            {
              "type" => "expression",
              "normative_status" => "preferred",
              "designation" => "승인 용어",
            },
          ],
          "language_code" => "kor",
          "entry_status" => "valid",
          "review_date" => Time.parse("2013-01-29 00:00:00 +08:00"),
          "review_decision_date" => Time.parse("2016-10-01 00:00:00 +08:00"),
          "review_decision_event" => "Publication of ISO 19104:2016",
        }
      end

      let(:rus_concept) do
        {
          "dates" => [
            {
              "date" => Time.parse("2008-11-15 00:00:00 +08:00"),
              "type" => "accepted",
            },
          ],
          "definition" => [
            {
              "content" => "термин, оцененный по шкале рейтинга приемлемости термина как синоним предпочтительного термина",
            },
          ],
          "examples" => [],
          "id" => "10",
          "lineage_source_similarity" => 1,
          "notes" => [],
          "release" => "2",
          "sources" => [
            {
              "origin" => {
                "ref" => "ISO 1087-1:2000",
                "link" => "https://www.iso.org/standard/20057.html",
              },
              "type" => "authoritative",
            },
          ],
          "terms" => [
            {
              "type" => "expression",
              "normative_status" => "preferred",
              "designation" => "допустимый термин",
            },
          ],
          "language_code" => "rus",
          "entry_status" => "valid",
        }
      end

      let(:spa_concept) do
        {
          "dates" => [
            {
              "date" => Time.parse("2008-11-15 00:00:00 +08:00"),
              "type" => "accepted",
            },
          ],
          "definition" => [
            {
              "content" => "término clasificado de acuerdo a la escala de aceptanción como un sinónimo de un término preferente",
            },
          ],
          "examples" => [],
          "id" => "10",
          "lineage_source_similarity" => 1,
          "notes" => [],
          "release" => "2",
          "sources" => [
            {
              "origin" => {
                "ref" => "ISO 1087-1:2000",
                "clause" => "3.4.16, modified — the Note 1 to entry has been added.",
                "link" => "https://www.iso.org/standard/20057.html",
              },
              "type" => "authoritative",
            },
          ],
          "terms" => [
            {
              "type" => "expression",
              "normative_status" => "preferred",
              "designation" => "término admitido",
            },
          ],
          "language_code" => "spa",
          "entry_status" => "valid",
          "review_date"=>Time.parse("2013-01-29 00:00:00 +08:00"),
          "review_decision_date"=>Time.parse("2016-10-01 00:00:00 +08:00"),
          "review_decision_event" => "Publication of ISO 19104:2016",
        }
      end

      let(:swe_concept) do
        {
          "dates" => [
            {
              "date"=>Time.parse("2008-11-15 00:00:00 +08:00"),
              "type" => "accepted",
            },
          ],
          "definition" => [
            {
              "content" => "term som bedömts vara lämplig för ett visst begrepp och som används vid sidan av en rekommenderad term",
            },
          ],
          "examples" => [],
          "id" => "10",
          "lineage_source_similarity" => 1,
          "notes" => [],
          "release" => "2",
          "sources" => [
            {
              "origin" => {
                "ref" => "ISO 1087-1:2000",
                "clause" => "3.4.16, modified — the Note 1 to entry has been added.",
                "link" => "https://www.iso.org/standard/20057.html",
              },
              "type" => "authoritative",
            },
          ],
          "terms" => [
            {
              "type" => "expression",
              "normative_status" => "preferred",
              "designation" => "tillåten term",
            },
          ],
          "language_code" => "swe",
          "entry_status" => "valid",
          "review_date" => Time.parse("2013-01-29 00:00:00 +08:00"),
          "review_decision_date" => Time.parse("2016-10-01 00:00:00 +08:00"),
          "review_decision_event" => "Publication of ISO 19104:2016",
        }
      end

      let(:expected_data) do
        {
          "id" => "18e02fe9-e52d-50a0-84ac-9fccae815fbd",
          "term" => "admitted term",
          "termid" => "10",
          "data" => {
            "identifier" => "10",
            "localized_concepts" => localized_concepts,
          },
          "eng" => eng_concept,
          "ara" => ara_concept,
          "dan" => dan_concept,
          "ger" => ger_concept,
          "kor" => kor_concept,
          "rus" => rus_concept,
          "spa" => spa_concept,
          "swe" => swe_concept,
        }
      end

      it "should change data count" do
        expect { load_glossary }.to change { subject.count }.from(0).to(1)
      end

      it "should load data" do
        load_glossary
        expect(subject["10"].data).to include(expected_data)
      end
    end
  end

  def add_concepts(*concept_hashes)
    concepts = concept_hashes.map { |h| described_class::Concept.new(h) }
    concepts.each { |c| instance.store c }
  end
end
