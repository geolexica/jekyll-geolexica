# (c) Copyright 2026 Ribose Inc.
#

RSpec.describe Jekyll::Geolexica::ConceptRDF do
  include RDFHelper

  SKOS_PREF = RDF::URI("http://www.w3.org/2004/02/skos/core#prefLabel")
  SKOS_ALT = RDF::URI("http://www.w3.org/2004/02/skos/core#altLabel")
  RDFS_LABEL = RDF::URI("http://www.w3.org/2000/01/rdf-schema#label")

  let(:site) do
    instance_double(
      Jekyll::Site,
      config: { "url" => "https://example.org", "geolexica" => { "term_languages" => %w[eng fra] } },
      data: { "lang" => { "eng" => { "iso-639-1" => "en", "lang_en" => "English" },
                          "fra" => { "iso-639-1" => "fr", "lang_en" => "French" } } },
    )
  end

  let(:concept) do
    Jekyll::Geolexica::Glossary::Concept.new(
      "termid" => "1",
      "eng" => { "language_code" => "eng",
                 "terms" => [{ "designation" => "thing", "normative_status" => "preferred", "type" => "expression" }],
                 "definition" => [], "dates" => [], "sources" => [], "entry_status" => "valid" },
    )
  end

  subject(:rdf) { described_class.new(concept, site) }

  context "a minimal concept" do
    let(:expected) do
      parse_ttl(<<~TTL)
        @prefix : <https://example.org/concepts/> .
        @prefix skos: <http://www.w3.org/2004/02/skos/core#> .
        @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
        @prefix dcterms: <http://purl.org/dc/terms/> .
        @prefix owl: <http://www.w3.org/2002/07/owl#> .
        @prefix rdf-profile: <https://example.org/api/rdf-profile#> .

        <https://example.org/concepts/>
          a owl:Ontology ;
          owl:imports <http://purl.org/dc/terms/> ;
          owl:imports <https://example.org/api/rdf-profile> ;
          owl:imports <http://www.w3.org/2004/02/skos/core> .

        :1 a skos:Concept ;
           rdf-profile:engOrigin rdf-profile:English ;
           rdf-profile:termID <https://example.org/concepts/1/> ;
           rdfs:label "thing" ;
           skos:notation "1" ;
           skos:inScheme rdf-profile:GeolexicaConceptScheme ;
           skos:prefLabel "thing"@en ;
           :status "valid" ;
           :classification "preferred" .

        :linked-data-api a dcterms:MediaTypeOrExtent ; skos:prefLabel "linked-data-api" .
      TTL
    end

    it "builds the full graph" do
      expect(rdf.to_graph).to be_isomorphic_with(expected)
    end

    it "turtle round-trips to the same graph" do
      expect(parse_ttl(rdf.to_ttl)).to be_isomorphic_with(rdf.to_graph)
    end

    it "json-ld round-trips to the same graph" do
      expect(parse_jsonld(rdf.to_jsonld)).to be_isomorphic_with(rdf.to_graph)
    end
  end

  context "with multiple languages and same-language altLabels" do
    let(:concept) do
      Jekyll::Geolexica::Glossary::Concept.new(
        "termid" => "1",
        "eng" => { "language_code" => "eng",
                   "terms" => [{ "designation" => "thing" }, { "designation" => "widget" }, { "designation" => "gadget" }],
                   "definition" => [{ "content" => "a thing" }], "dates" => [], "sources" => [], "entry_status" => "valid" },
        "fra" => { "language_code" => "fra", "terms" => [{ "designation" => "chose" }],
                   "definition" => [{ "content" => "une chose" }], "dates" => [], "sources" => [], "entry_status" => "valid" },
      )
    end

    let(:subject_iri) { RDF::URI("https://example.org/concepts/1") }

    it "keeps every designation including same-language altLabels with correct tags" do
      pref = rdf.to_graph.query([subject_iri, SKOS_PREF, nil]).objects
      alt = rdf.to_graph.query([subject_iri, SKOS_ALT, nil]).objects
      expect(pref.map(&:to_s)).to contain_exactly("thing", "chose")
      expect(alt.map(&:to_s)).to contain_exactly("widget", "gadget")
      expect(alt.map(&:language)).to contain_exactly(:en, :en)
    end

    it "json-ld preserves same-language altLabels" do
      expect(parse_jsonld(rdf.to_jsonld)).to be_isomorphic_with(rdf.to_graph)
    end
  end

  context "a full concept (699-shaped, exercises B1/B2/B4)" do
    let(:concept) do
      Jekyll::Geolexica::Glossary::Concept.new(
        "termid" => "699",
        "eng" => {
          "language_code" => "eng",
          "terms" => [{ "designation" => "UML application schema", "normative_status" => "preferred" }],
          "definition" => [{ "content" => "application schema written in UML" }],
          "dates" => [{ "date" => "2007-09-01T00:00:00+05:00", "type" => "accepted" },
                      { "date" => "2020-01-09T00:00:00+05:00", "type" => "amended" }],
          "sources" => [{ "type" => "authoritative",
                          "origin" => { "ref" => "ISO 19136-1:2020", "link" => "https://www.iso.org/standard/75676.html" } }],
          "entry_status" => "valid",
        },
        "fra" => { "language_code" => "fra", "terms" => [{ "designation" => "schéma" }],
                   "definition" => [], "dates" => [], "sources" => [], "entry_status" => "valid" },
      )
    end

    let(:expected) do
      parse_ttl(<<~TTL)
        @prefix : <https://example.org/concepts/> .
        @prefix dcterms: <http://purl.org/dc/terms/> .
        @prefix owl: <http://www.w3.org/2002/07/owl#> .
        @prefix rdf-profile: <https://example.org/api/rdf-profile#> .
        @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
        @prefix skos: <http://www.w3.org/2004/02/skos/core#> .

        <https://example.org/concepts/> a owl:Ontology ;
          owl:imports <http://purl.org/dc/terms/>, <https://example.org/api/rdf-profile>, <http://www.w3.org/2004/02/skos/core> .

        :699 a skos:Concept ;
          rdf-profile:engOrigin rdf-profile:English ;
          rdf-profile:fraOrigin rdf-profile:French ;
          rdf-profile:termID <https://example.org/concepts/699/> ;
          rdfs:label "UML application schema" ;
          skos:notation "699" ;
          skos:definition "application schema written in UML"@en ;
          skos:inScheme rdf-profile:GeolexicaConceptScheme ;
          skos:prefLabel "UML application schema"@en, "schéma"@fr ;
          dcterms:source "https://www.iso.org/standard/75676.html" ;
          dcterms:dateAccepted "2007-09-01" ;
          dcterms:modified "2020-01-09" ;
          :status "valid" ;
          :classification "preferred" .

        :linked-data-api a dcterms:MediaTypeOrExtent ; skos:prefLabel "linked-data-api" .
      TTL
    end

    it "matches the full expected graph" do
      expect(rdf.to_graph).to be_isomorphic_with(expected)
    end

    it "turtle and json-ld are isomorphic to each other" do
      expect(parse_jsonld(rdf.to_jsonld)).to be_isomorphic_with(parse_ttl(rdf.to_ttl))
    end
  end

  context "special characters in literals (B3: no HTML escaping)" do
    let(:concept) do
      Jekyll::Geolexica::Glossary::Concept.new("termid" => "x",
        "eng" => { "language_code" => "eng", "terms" => [{ "designation" => %(A & B <C> "D") }],
                   "definition" => [], "dates" => [], "sources" => [], "entry_status" => "valid" })
    end

    it "stores the raw literal value, not HTML entities" do
      label = rdf.to_graph.query([RDF::URI("https://example.org/concepts/x"), RDFS_LABEL, nil]).objects.first
      expect(label.to_s).to eq(%(A & B <C> "D"))
      expect(label.to_s).not_to include("&amp;")
    end

    it "round-trips through both serializations" do
      expect(parse_ttl(rdf.to_ttl)).to be_isomorphic_with(rdf.to_graph)
      expect(parse_jsonld(rdf.to_jsonld)).to be_isomorphic_with(rdf.to_graph)
    end
  end

  context "a concept with no English localization" do
    let(:site) do
      instance_double(Jekyll::Site,
        config: { "url" => "https://example.org", "geolexica" => { "term_languages" => %w[fra] } },
        data: { "lang" => { "fra" => { "iso-639-1" => "fr", "lang_en" => "French" } } })
    end
    let(:concept) do
      Jekyll::Geolexica::Glossary::Concept.new("termid" => "f",
        "fra" => { "language_code" => "fra", "terms" => [{ "designation" => "chose", "normative_status" => "preferred" }],
                   "definition" => [], "dates" => [], "sources" => [], "entry_status" => "valid" })
    end

    it "omits English-anchored fields and still emits French labels (matches template)" do
      subject_iri = RDF::URI("https://example.org/concepts/f")
      expect { rdf.to_graph }.not_to raise_error
      expect(rdf.to_graph.query([subject_iri, RDFS_LABEL, nil]).count).to eq(0)
      expect(rdf.to_graph.query([subject_iri, RDF::URI("https://example.org/concepts/status"), nil]).count).to eq(0)
      pref = rdf.to_graph.query([subject_iri, SKOS_PREF, nil]).objects
      expect(pref.map(&:to_s)).to contain_exactly("chose")
    end
  end

  context "against the real V2 termid 699 fixture" do
    before do
      allow_any_instance_of(::Jekyll::Geolexica::Glossary)
        .to receive(:glossary_path).and_return(fixture_path("v2_glossary"))
    end

    let(:lang_data) do
      YAML.safe_load(File.read(File.expand_path("../../../../_data/lang.yaml", __dir__)))
    end
    let(:site) do
      instance_double(Jekyll::Site,
        config: { "url" => "https://example.org",
                  "geolexica" => { "term_languages" => %w[eng ara kor rus spa] } },
        data: { "lang" => lang_data })
    end
    let(:concept) do
      glossary = ::Jekyll::Geolexica::Glossary.new(site)
      glossary.send(:load_glossary)
      glossary["699"]
    end

    it "turtle and json-ld are isomorphic to each other" do
      expect(parse_jsonld(rdf.to_jsonld)).to be_isomorphic_with(parse_ttl(rdf.to_ttl))
    end

    it "includes the concept subject" do
      expect(rdf.to_graph.subjects.to_a).to include(RDF::URI("https://example.org/concepts/699"))
    end
  end

  context "a definition containing a math construct" do
    let(:concept) do
      Jekyll::Geolexica::Glossary::Concept.new("termid" => "m",
        "eng" => { "language_code" => "eng", "terms" => [{ "designation" => "energy" }],
                   "definition" => [{ "content" => 'E = stem:[mc^2]' }], "dates" => [], "sources" => [], "entry_status" => "valid" })
    end

    it "serializes without corrupting the literal" do
      expect(parse_ttl(rdf.to_ttl)).to be_isomorphic_with(rdf.to_graph)
    end
  end
end
