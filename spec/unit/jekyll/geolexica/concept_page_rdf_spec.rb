# (c) Copyright 2026 Ribose Inc.
#

RSpec.describe "ConceptPage RDF formats" do
  include RDFHelper

  let(:site) do
    instance_double(Jekyll::Site,
      config: { "url" => "https://example.org", "geolexica" => { "term_languages" => %w[eng] } },
      data: { "lang" => { "eng" => { "iso-639-1" => "en", "lang_en" => "English" } } },
      source: ".")
  end
  let(:concept) do
    Jekyll::Geolexica::Glossary::Concept.new("termid" => "1",
      "eng" => { "language_code" => "eng", "terms" => [{ "designation" => "thing" }],
                 "definition" => [], "dates" => [], "sources" => [], "entry_status" => "valid" })
  end

  it "Turtle page content equals ConceptRDF and uses no liquid" do
    page = Jekyll::Geolexica::ConceptPage::Turtle.new(site, concept)
    expected = Jekyll::Geolexica::ConceptRDF.new(concept, site).to_graph
    expect(parse_ttl(page.content)).to be_isomorphic_with(expected)
    expect(page.data["render_with_liquid"]).to eq(false)
    expect(page.data["layout"]).to be_nil
  end

  it "JSON-LD page content equals ConceptRDF" do
    page = Jekyll::Geolexica::ConceptPage::JSONLD.new(site, concept)
    expected = Jekyll::Geolexica::ConceptRDF.new(concept, site).to_graph
    expect(parse_jsonld(page.content)).to be_isomorphic_with(expected)
  end
end
