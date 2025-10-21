# (c) Copyright 2020 Ribose Inc.
#

module Jekyll
  module Geolexica
    module Configuration
      def concepts_glob
        glob_string = glossary_config["concepts_glob"]
        File.expand_path(glob_string, site.source)
      end

      def localized_concepts_path
        path = glossary_config["localized_concepts_path"]
        return nil if path.nil? || path.empty?

        File.expand_path(path, site.source)
      end

      def glossary_path
        glob_string = glossary_config["glossary_path"]
        File.expand_path(glob_string, site.source)
      end

      def glossary_format
        glossary_config["format"]
      end

      def images_path
        glossary_path = glossary_config["glossary_path"]
        return nil if glossary_path.nil? || glossary_path.empty?

        File.expand_path("#{glossary_path}/images", site.source)
      end

      def images_metadata_path
        images_metadata_path = glossary_config["images_metadata_path"] ||
          glossary_config["glossary_path"]

        return {} if images_metadata_path.nil? || images_metadata_path.empty?

        File.expand_path(
          "#{images_metadata_path}/images_metadata.yaml", site.source
        )
      end

      def bibliography_path
        bibliography_path = glossary_config["bibliography_path"] ||
          glossary_config["glossary_path"]
        return nil if bibliography_path.nil? || bibliography_path.empty?

        File.expand_path("#{bibliography_path}/bibliography.yaml", site.source)
      end

      def suggest_translation_url
        glossary_config["suggest_translation_url"]
      end

      def report_issue_url
        glossary_config["report_issue_url"]
      end

      def term_languages
        glossary_config["term_languages"]
      end

      def output_html?
        glossary_config["formats"].include?("html")
      end

      def output_json?
        glossary_config["formats"].include?("json")
      end

      def output_jsonld?
        glossary_config["formats"].include?("json-ld")
      end

      def output_tbx?
        glossary_config["formats"].include?("tbx-iso-tml")
      end

      def output_turtle?
        glossary_config["formats"].include?("turtle")
      end

      def output_yaml?
        glossary_config["formats"].include?("yaml")
      end

      protected

      def glossary_config
        site.config["geolexica"] || {}
      end
    end
  end
end
