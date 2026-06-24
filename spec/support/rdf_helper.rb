# (c) Copyright 2026 Ribose Inc.
#

require "rdf"
require "rdf/turtle"
require "json/ld"
require "rdf/isomorphic"

module RDFHelper
  def parse_ttl(string)
    RDF::Graph.new.tap do |graph|
      RDF::Turtle::Reader.new(string).each_statement { |s| graph << s }
    end
  end

  def parse_jsonld(string)
    RDF::Graph.new.tap do |graph|
      RDF::Reader.for(:jsonld).new(string).each_statement { |s| graph << s }
    end
  end
end

RSpec::Matchers.define :be_isomorphic_with do |expected|
  match { |actual| actual.isomorphic_with?(expected) }
  failure_message do |actual|
    "expected graph (#{actual.count} stmts) to be isomorphic with " \
      "expected (#{expected.count} stmts).\n--- actual ---\n#{actual.dump(:ttl)}\n" \
      "--- expected ---\n#{expected.dump(:ttl)}"
  end
end

RSpec::Matchers.define :have_statement do |statement|
  match { |graph| graph.has_statement?(statement) }
end

RSpec.configure do |config|
  config.include RDFHelper
end
