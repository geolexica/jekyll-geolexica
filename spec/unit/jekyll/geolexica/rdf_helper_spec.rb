# (c) Copyright 2026 Ribose Inc.
#

RSpec.describe "RDFHelper" do
  include RDFHelper

  let(:ttl) do
    <<~TTL
      @prefix skos: <http://www.w3.org/2004/02/skos/core#> .
      <http://example.org/c/1> a skos:Concept ; skos:prefLabel "x"@en .
    TTL
  end

  it "parses turtle into a graph" do
    expect(parse_ttl(ttl).count).to eq(2)
  end

  it "round-trips turtle and json-ld to isomorphic graphs" do
    graph = parse_ttl(ttl)
    expect(parse_jsonld(graph.dump(:jsonld))).to be_isomorphic_with(graph)
  end
end
