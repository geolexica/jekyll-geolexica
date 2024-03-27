# (c) Copyright 2020 Ribose Inc.
#

module Jekyll
  module Geolexica
    module Hooks
      module_function

      def register_all_hooks
        hook :after_init, :site, :initialize_glossary
        hook :post_read, :site, :load_glossary
        hook :pre_render, :documents, :expose_glossary
        hook :pre_render, :pages, :expose_glossary
        hook :post_render, :pages, :convert_math
      end

      # Adds Jekyll::Site#glossary method, and initializes an empty glossary.
      def initialize_glossary(site)
        site.class.attr_reader :glossary
        site.instance_variable_set "@glossary", Glossary.new(site)
      end

      # Loads concept data into glossary.
      def load_glossary(site)
        site.glossary.load_glossary
      end

      def expose_glossary(page_or_document, liquid_drop)
        liquid_drop["glossary"] = page_or_document.site.glossary
      end

      def convert_math(page)
        prefix_hash = {
          asciimath: "stem",
          latex: "latexmath",
        }

        prefix_hash.each do |math_notation, prefix|
          page.output.gsub!(/#{prefix}:(?<re>\[((?>[^\[\]]+)|\g<re>)*\])/) do
            ascii_equation = CGI.unescapeHTML(Regexp.last_match[1])[1..-2]

            mathml_equation = ::Plurimath::Math
                                .parse(ascii_equation, math_notation)
                                .to_mathml

            normalize_mathml(mathml_equation, page.html?)
          end
        end
      rescue => e
        # Skipping broken formulas
        Jekyll.logger.info(e.message)
      end

      def normalize_mathml(mathml_equation, is_html)
        # temporary hack to use display inline for math equations because
        # currently there is no option to use display inline in plurimath
        mathml_equation = mathml_equation.gsub("display=\"block\"", "display=\"inline\"")

        # Removing newlines(\n) and escaping double quotes(")
        # because they will cause parsing issues in json
        mathml_equation = mathml_equation.gsub("\n", "").gsub("\"", "\\\"") unless is_html

        mathml_equation
      end

      def hook event, target, action
        Jekyll::Hooks.register target, event, &method(action)
      end
    end
  end
end
