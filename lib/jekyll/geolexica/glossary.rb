# (c) Copyright 2020 Ribose Inc.
#

module Jekyll
  module Geolexica
    class Glossary < Hash
      include Configuration

      attr_reader :site

      alias each_concept each_value
      alias each_termid each_key

      def initialize(site)
        @site = site
        @collection = Glossarist::ManagedConceptCollection.new
      end

      def load_glossary
        Jekyll.logger.info("Geolexica:", "Loading concepts")
        @collection.load_from_files(glossary_path)

        @collection.each do |managed_concept|
          concept_hash = {
            "id" => managed_concept.uuid,
            "term" => managed_concept.default_designation,
            "termid" => managed_concept.data.id,
            "status" => managed_concept.status,
          }.merge(managed_concept.to_yaml_hash)

          managed_concept.localizations.each do |lang, localization|
            concept_hash[lang] =
              localization.to_yaml_hash["data"].merge({ "status" => localization.entry_status })
          end

          preprocess_concept_hash(concept_hash)
          store(Concept.new(concept_hash))
        end
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

      # Does nothing, but some sites may replace this method.
      def preprocess_concept_hash(concept_hash); end

      def calculate_language_statistics
        unsorted = each_value.lazy
          .flat_map { |concept| term_languages & concept.data.keys }
          .group_by(&:itself)
          .transform_values(&:count)

        # This is not crucial, but gives nicer output, and ensures that
        # all +term_languages+ are present.
        term_languages.to_h { |key| [key, unsorted[key] || 0] }
      end

      class Concept
        attr_reader :data

        # TODO: Maybe some kind of Struct instead of Hash.
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
