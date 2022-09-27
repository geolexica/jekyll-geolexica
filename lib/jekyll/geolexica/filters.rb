# (c) Copyright 2020 Ribose Inc.
#

module Jekyll
  module Geolexica
    module Filters
      # Renders authoritative source hash as HTML.
      #
      # @param input [Hash] authoritative source hash.
      # @return [String]
      #
      # TODO Maybe support string inputs.
      def display_authoritative_source(input)
        ref, clause, link = input["origin"].values_at("ref", "clause", "link") rescue nil

        return "" if ref.nil? && link.nil?

        ref_caption = escape_once(ref || link)
        ref_part = link ? %[<a href="#{link}">#{ref_caption}</a>] : ref_caption

        clause_part = clause && escape_once(clause)

        source = [ref_part, clause_part].compact.join(", ")

        modification = input["modification"]
        return source unless modification

        "#{source}, modified -- #{modification}"
      end

      def concepts_url(base_url)
        return if !base_url || base_url.empty?

        if base_url.end_with?("/")
          "#{base_url}concepts/"
        else
          "#{base_url}/concepts/"
        end
      end

      def extract_concept_id(url)
        return if !url || url.empty?

        url.split("/").last
      end

      URN_REFERENCE_REGEX = /{{(urn:[^,}]*),?([^,}]*),?([^}]*)?}}/.freeze
      REFERENCE_REGEX = /(?:&lt;|<){2}((?!:&gt;:&gt;).*?)(?:&gt;|>){2}/.freeze

      def resolve_reference_to_links(text)
        return text if text.nil?

        text.gsub!(URN_REFERENCE_REGEX) do |reference|
          urn = Regexp.last_match[1]

          if !urn || urn.empty?
            reference
          else
            link_tag_from_urn(urn, Regexp.last_match[2], Regexp.last_match[3])
          end
        end

        text.gsub!(REFERENCE_REGEX) do |reference|
          ref = Regexp.last_match[1]
          return reference if ref.start_with?("fig")

          link_tag_from_ref(ref.split(",").first)
        end

        text
      end

      def link_tag_from_urn(urn, term_referenced, term_to_show)
        clause = urn.split(":").last
        term_to_show = term_to_show.empty? ? term_referenced : term_to_show

        link_tag("/concepts/#{clause}", term_to_show)
      end

      def link_tag_from_ref(ref)
        return ref if @context.registers[:site].data["bibliography"].nil?

        bib_ref = @context.registers[:site].data["bibliography"][ref]

        if bib_ref["user_defined"]
          link = bib_ref["link"]
          docidentifier = bib_ref["reference"]
        else
          link = bib_ref["link"].detect { |l| l["type"] == "src" }["content"]["uri_string"]
          docidentifier = bib_ref["docidentifier"].detect { |d| d["primary"] }["id"]
        end

        link_tag(link, docidentifier)
      end

      def link_tag(link, text)
        return text if link.nil? || link.empty?

        "<a href=\"#{link}\">#{text}<\/a>"
      end

      IMAGE_REGEX = /(?:<|&lt;){2}(fig_.*?)(?:>|&gt;){2}/.freeze

      def add_images(text)
        return text if text.nil?

        images = []

        text.gsub!(IMAGE_REGEX) do
          image_name = Regexp.last_match[1]
          metadata = images_metadata[image_name]

          images << image_tag(image_name, metadata, width: "100%")

          metadata["clause"]
        end

        text + images.join("\n\n")
      end

      def image_tag(image_name, metadata, options = {})
        options_str = options.map do |name, value|
          %(#{name} = "#{value}")
        end.join(" ")

        title = "#{metadata['clause']} — #{metadata['caption']}"

        <<~TEMPLATE
          <img src="/concepts/images/#{image_name}.png" #{options_str}>
          <div style="font-weight: bold;">#{title}</div>
        TEMPLATE
      end

      def images_metadata
        site = @context.registers[:site]
        glossary_path = site.config["geolexica"]["glossary_path"]
        return {} if glossary_path.nil? || glossary_path.empty?

        @images_metadata ||= YAML.load_file(
          File.expand_path("#{glossary_path}/images_metadata.yaml", site.source),
        )
      end

      def display_terminological_data(term)
        result = []

        result << "&lt;#{term['usage_info']}&gt;" if term["usage_info"]
        result << extract_grammar_info(term)
        result << term["geographical_area"]&.upcase

        result.unshift(",") if result.compact.size.positive?

        result.compact.join(" ")
      end

      def extract_grammar_info(term)
        return unless term["grammar_info"]

        grammar_info = []

        term["grammar_info"].each do |info|
          grammar_info << info["gender"]&.join(", ")
          grammar_info << info["number"]&.join(", ")
          grammar_info << extract_parts_of_speech(info)
        end

        grammar_info.join(" ")
      end

      def extract_parts_of_speech(grammar_info)
        parts_of_speech = grammar_info.dup || {}

        %w[number gender].each do |key|
          parts_of_speech.delete(key)
        end

        parts_of_speech
          .select { |_key, value| value }
          .keys
          .compact
          .join(", ")
      end

      ABBREVIATION_TYPES = %w[
        truncation
        acronym
        initialism
      ].freeze

      # check if the given term is an abbreviation or not
      def abbreviation?(term)
        ABBREVIATION_TYPES.include?(term["type"])
      end

      def preferred?(term)
        term["normative_status"] == "preferred"
      end

      def deprecated?(term)
        term["normative_status"] == "deprecated"
      end

      def get_authoritative(sources)
        sources&.find { |source| source["type"] == "authoritative" }
      end
    end
  end
end

Liquid::Template.register_filter(Jekyll::Geolexica::Filters)
