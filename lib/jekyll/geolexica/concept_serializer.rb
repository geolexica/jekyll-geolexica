# (c) Copyright 2020 Ribose Inc.
#

module Jekyll
  module Geolexica
    # A decorator responsible for serializing concepts in the most simplistic
    # machine-readable formats like JSON or YAML but unlike RDF ontologies.
    class ConceptSerializer < SimpleDelegator
      include Configuration

      NON_LANGUAGE_KEYS = %w[term termid]

      # A Jekyll::Site instance.
      attr_reader :site

      def initialize(concept, site)
        super(concept)
        @site = site
      end

      def to_json
        JSON.dump(in_all_languages)
      end

      def to_yaml
        YAML.dump(in_all_languages)
      end

      private

      # Returns concept hash in all supported languages, with +nil+ value for
      # every supported language that this concept is not translated to.
      def in_all_languages(concept_hash = data)
        hash_keys = NON_LANGUAGE_KEYS + term_languages
        slice_hash_with_default(concept_hash, nil, *hash_keys)
      end

      # Like Hash#slice, but takes a +default_value+, which is used for every
      # key not present in the +hash+.
      def slice_hash_with_default(hash, default_value, *keys)
        h = hash.dup
        keys.each { |k| h[k] ||= default_value }
        h.slice(*keys)
      end
    end
  end
end
