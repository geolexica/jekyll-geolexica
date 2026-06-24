# (c) Copyright 2026 Ribose Inc.
#

require "rdf"
require "rdf/turtle"
require "json/ld"
require "date"

module Jekyll
  module Geolexica
    # Builds one RDF::Graph per concept (raw ruby-rdf) and serializes it to
    # Turtle and JSON-LD. Reads the concept's flattened string-keyed Hash, the
    # same data the former Liquid templates consumed.
    class ConceptRDF
      SKOS = RDF::Vocabulary.new("http://www.w3.org/2004/02/skos/core#")
      RDFS = RDF::Vocabulary.new("http://www.w3.org/2000/01/rdf-schema#")
      DCTERMS = RDF::Vocabulary.new("http://purl.org/dc/terms/")
      OWL = RDF::Vocabulary.new("http://www.w3.org/2002/07/owl#")
      PROFILE_SUBPATH = "/api/rdf-profile".freeze
      SKOS_BASE = "http://www.w3.org/2004/02/skos/core".freeze
      SOURCE_LANG = "eng".freeze

      attr_reader :concept, :site

      def initialize(concept, site)
        @concept = concept
        @site = site
      end

      def to_graph
        @to_graph ||= RDF::Graph.new.tap { |graph| graph.insert(*statements) }
      end

      def to_ttl
        RDF::Turtle::Writer.buffer(prefixes: ttl_prefixes) do |writer|
          to_graph.each_statement { |statement| writer << statement }
        end
      end

      def to_jsonld
        JSON::LD::Writer.buffer(context: jsonld_context) do |writer|
          to_graph.each_statement { |statement| writer << statement }
        end
      end

      private

      def data
        concept.data
      end

      def termid
        concept.termid
      end

      # site.config["url"] is the site root; matches the `concepts_url` filter.
      def site_url
        site.config["url"].to_s.chomp("/")
      end

      def base_url
        "#{site_url}/concepts/"
      end

      # rdf-profile is a SITE-ROOT path. The legacy template's relative
      # "/api/rdf-profile#" resolves against @base to this absolute IRI, so we
      # build it absolute (relative IRIs break JSON-LD round-tripping).
      def profile_path
        "#{site_url}#{PROFILE_SUBPATH}"
      end

      def profile_ns
        "#{profile_path}#"
      end

      def subject
        @subject ||= RDF::URI("#{base_url}#{termid}")
      end

      def profile_uri(local)
        RDF::URI("#{profile_ns}#{local}")
      end

      def base_uri(local)
        RDF::URI("#{base_url}#{local}")
      end

      def term_languages
        Array(site.config.dig("geolexica", "term_languages"))
      end

      def language_tag(lang)
        site.data.dig("lang", lang, "iso-639-1")
      end

      def localized(lang)
        data[lang] || {}
      end

      # Concept-level fields are English-anchored, matching the template.
      def source_data
        data[SOURCE_LANG] || {}
      end

      def langs_with_terms
        term_languages.select { |lang| Array(localized(lang)["terms"]).any? }
      end

      def lang_literal(value, lang)
        RDF::Literal.new(value, language: language_tag(lang))
      end

      def statements
        ontology_statements + concept_statements + linked_data_api_statements
      end

      def ontology_statements
        ontology = RDF::URI(base_url)
        [
          RDF::Statement(ontology, RDF.type, OWL.Ontology),
          RDF::Statement(ontology, OWL.imports, DCTERMS.to_uri),
          RDF::Statement(ontology, OWL.imports, RDF::URI(profile_path)),
          RDF::Statement(ontology, OWL.imports, RDF::URI(SKOS_BASE)),
        ]
      end

      def linked_data_api_statements
        node = base_uri("linked-data-api")
        [
          RDF::Statement(node, RDF.type, DCTERMS.MediaTypeOrExtent),
          RDF::Statement(node, SKOS.prefLabel, RDF::Literal("linked-data-api")),
        ]
      end

      def concept_statements
        [
          RDF::Statement(subject, RDF.type, SKOS.Concept),
          *origin_statements,
          RDF::Statement(subject, profile_uri("termID"), RDF::URI("#{base_url}#{termid}/")),
          label_statement,
          RDF::Statement(subject, SKOS.notation, RDF::Literal(termid)),
          *definition_statements,
          RDF::Statement(subject, SKOS.inScheme,
                         profile_uri("GeolexicaConceptScheme")),
          *pref_label_statements,
          *alt_label_statements,
          source_statement,
          *date_statements,
          status_statement,
          classification_statement,
        ].compact
      end

      # rdf-profile:{lang}Origin rdf-profile:{LangEn} -- predicate AND object
      # are both derived from the language.
      def origin_statements
        langs_with_terms.map do |lang|
          RDF::Statement(subject, profile_uri("#{lang}Origin"),
                         profile_uri(site.data.dig("lang", lang, "lang_en")))
        end
      end

      def label_statement
        designation = source_data.dig("terms", 0, "designation")
        designation && RDF::Statement(subject, RDFS.label, RDF::Literal(designation))
      end

      def definition_statements
        term_languages.flat_map do |lang|
          Array(localized(lang)["definition"]).map do |definition|
            RDF::Statement(subject, SKOS.definition,
                           lang_literal(definition["content"], lang))
          end
        end
      end

      def pref_label_statements
        term_languages.filter_map do |lang|
          term = Array(localized(lang)["terms"]).first
          term && RDF::Statement(subject, SKOS.prefLabel,
                                 lang_literal(term["designation"], lang))
        end
      end

      def alt_label_statements
        term_languages.flat_map do |lang|
          Array(localized(lang)["terms"]).drop(1).map do |term|
            RDF::Statement(subject, SKOS.altLabel,
                           lang_literal(term["designation"], lang))
          end
        end
      end

      # B1: read the link nested under origin (template's direct .link was nil).
      def source_statement
        source = Array(source_data["sources"]).find do |s|
          s["type"] == "authoritative"
        end
        link = source && (source.dig("origin",
                                     "link") || source.dig("origin", "ref"))
        link && RDF::Statement(subject, DCTERMS.source, RDF::Literal(link))
      end

      # B2: read dates from the dates array (template read non-existent keys).
      def date_statements
        Array(source_data["dates"]).filter_map do |entry|
          predicate = { "accepted" => DCTERMS.dateAccepted,
                        "amended" => DCTERMS.modified }[entry["type"]]
          predicate && entry["date"] &&
            RDF::Statement(subject, predicate, RDF::Literal(format_date(entry["date"])))
        end
      end

      def format_date(value)
        Date.parse(value.to_s).strftime("%F")
      end

      def status_statement
        status = source_data["entry_status"]
        status && RDF::Statement(subject, base_uri("status"), RDF::Literal(status))
      end

      def classification_statement
        classification = source_data.dig("terms", 0, "normative_status")
        classification && RDF::Statement(subject, base_uri("classification"), RDF::Literal(classification))
      end

      def ttl_prefixes
        {
          :"" => base_url,
          "rdf-profile" => profile_ns,
          "skos" => SKOS.to_uri.to_s,
          "rdfs" => RDFS.to_uri.to_s,
          "dcterms" => DCTERMS.to_uri.to_s,
          "owl" => OWL.to_uri.to_s,
        }
      end

      def jsonld_context
        ttl_prefixes.reject { |prefix, _| prefix == :"" }.transform_keys(&:to_s)
      end
    end
  end
end
