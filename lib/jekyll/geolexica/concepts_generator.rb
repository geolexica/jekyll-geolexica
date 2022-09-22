# (c) Copyright 2020 Ribose Inc.
#

module Jekyll
  module Geolexica
    class ConceptsGenerator < Generator
      include Configuration

      safe true

      attr_reader :generated_pages, :site

      # Generates Geolexica concept pages, both HTML and machine-readable.
      def generate(site)
        Jekyll.logger.info("Geolexica:", "Generating concept pages")

        # Jekyll does not say why it's a good idea, and whether such approach
        # is thread-safe or not, but most plugins in the wild do exactly that,
        # including these authored by Jekyll team.
        @site = site
        @generated_pages = []

        make_pages
        sort_pages
        initialize_collections
        group_pages_in_collections
      end

      # Processes concepts and yields a bunch of Jekyll::Page instances.
      def make_pages
        site.glossary.each_concept do |concept|
          Jekyll.logger.debug("Geolexica:",
            "building pages for concept #{concept.termid}")
          concept.pages.replace({
            html: (ConceptPage::HTML.new(site, concept) if output_html?),
            json: (ConceptPage::JSON.new(site, concept) if output_json?),
            jsonld: (ConceptPage::JSONLD.new(site, concept) if output_jsonld?),
            tbx: (ConceptPage::TBX.new(site, concept) if output_tbx?),
            turtle: (ConceptPage::Turtle.new(site, concept) if output_turtle?),
            yaml: (ConceptPage::YAML.new(site, concept) if output_yaml?),
          })
          add_page(*concept.pages.values.compact)
        end
      end

      def sort_pages
        generated_pages.sort_by! { |p| p.termid }
      end

      def initialize_collections
        %w[
          concepts concepts_json concepts_jsonld
          concepts_ttl concepts_tbx concepts_yaml
        ].each do |label|
          next if site.collections[label]
          site.config["collections"][label] ||= { "output" => true }
          site.collections[label] = Jekyll::Collection.new(site, label)
        end
      end

      def group_pages_in_collections
        generated_pages.each do |page|
          site.collections[page.collection_name].docs.push(page)
        end
      end

      def add_page *pages
        self.generated_pages.concat(pages)
      end

      def find_page(name)
        site.pages.detect { |page| page.name == name }
      end
    end
  end
end
