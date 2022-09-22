# (c) Copyright 2020 Ribose Inc.
#

module Jekyll
  module Geolexica
    class ConceptPage < PageWithoutAFile
      attr_reader :concept

      def initialize(site, concept)
        @concept = concept
        @data = default_data.merge(concept.data)

        super(site, site.source, "concepts", page_name)
      end

      def termid
        concept.termid
      end

      def type
        self.collection_name.to_sym
      end

      protected

      def default_data
        {
          "layout" => layout,
          "render_with_liquid" => uses_liquid,
          "permalink" => permalink,
          "representations" => concept.pages,
        }
      end

      class HTML < ConceptPage
        def page_name
          "#{termid}.html"
        end

        def collection_name
          "concepts"
        end

        def layout
          "concept"
        end

        def uses_liquid
          true
        end

        def permalink
          "/concepts/#{termid}/"
        end
      end

      class JSON < ConceptPage
        def page_name
          "#{termid}.json"
        end

        def collection_name
          "concepts_json"
        end

        def layout
          nil
        end

        def content
          ConceptSerializer.new(concept, site).to_json
        end

        def uses_liquid
          false
        end

        def permalink
          "/api/concepts/#{termid}.json"
        end
      end

      class JSONLD < ConceptPage
        def page_name
          "#{termid}.jsonld"
        end

        def collection_name
          "concepts_jsonld"
        end

        def layout
          "concept.jsonld"
        end

        def uses_liquid
          true
        end

        def permalink
          "/api/concepts/#{termid}.jsonld"
        end
      end

      class Turtle < ConceptPage
        def page_name
          "#{termid}.ttl"
        end

        def collection_name
          "concepts_ttl"
        end

        def layout
          "concept.ttl"
        end

        def uses_liquid
          true
        end

        def permalink
          "/api/concepts/#{termid}.ttl"
        end
      end

      class TBX < ConceptPage
        def page_name
          "#{termid}.tbx.xml"
        end

        def collection_name
          "concepts_tbx"
        end

        def layout
          "concept.tbx.xml"
        end

        def uses_liquid
          true
        end

        def permalink
          "/api/concepts/#{termid}.tbx.xml"
        end
      end

      class YAML < ConceptPage
        def page_name
          "#{termid}.yaml"
        end

        def collection_name
          "concepts_yaml"
        end

        def layout
          nil
        end

        def content
          ConceptSerializer.new(concept, site).to_yaml
        end

        def uses_liquid
          false
        end

        def permalink
          "/api/concepts/#{termid}.yaml"
        end
      end

    end
  end
end
