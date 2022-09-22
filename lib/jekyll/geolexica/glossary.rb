# (c) Copyright 2020 Ribose Inc.
#

module Jekyll
  module Geolexica
    class Glossary < Hash
      include Configuration

      attr_reader :site

      alias_method :each_concept, :each_value
      alias_method :each_termid, :each_key

      def initialize(site)
        @site = site
      end

      def load_glossary
        Jekyll.logger.info("Geolexica:", "Loading concepts")
        Dir.glob(concepts_glob).each { |path| load_concept(path) }
      end

      def store(concept)
        super(concept.data["termid"], concept)
      end

      def language_statistics
        @language_statistics ||= calculate_language_statistics
      end

      # Defines how Glossary is exposed in Liquid templates.
      def to_liquid
        {
          "language_statistics" => language_statistics,
        }
      end

      protected

      def load_concept(concept_file_path)
        Jekyll.logger.debug("Geolexica:",
          "reading concept from file #{concept_file_path}")
        concept_hash = read_concept_file(concept_file_path)
        preprocess_concept_hash(concept_hash)
        store Concept.new(concept_hash)
      rescue
        Jekyll.logger.error("Geolexica:",
          "failed to read concept from file #{concept_file_path}")
        raise
      end

      # Reads and parses concept file located at given path.
      def read_concept_file(path)
        YAML.load(File.read path)
      end

      # Does nothing, but some sites may replace this method.
      def preprocess_concept_hash(concept_hash)
      end

      def calculate_language_statistics
        unsorted = each_value.lazy.
          flat_map{ |concept| term_languages & concept.data.keys }.
          group_by(&:itself).
          transform_values(&:count)

        # This is not crucial, but gives nicer output, and ensures that
        # all +term_languages+ are present.
        term_languages.to_h { |key| [key, unsorted[key] || 0] }
      end

      class Concept
        attr_reader :data

        # TODO Maybe some kind of Struct instead of Hash.
        attr_reader :pages

        def initialize(data)
          @data = data
          @pages = LiquidCompatibleHash.new
        end

        def termid
          data["termid"]
        end

        class LiquidCompatibleHash < Hash
          def to_liquid
            Jekyll::Utils.stringify_hash_keys(self)
          end
        end
      end
    end
  end
end
