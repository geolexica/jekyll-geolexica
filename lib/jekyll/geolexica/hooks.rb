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

      def hook event, target, action
        Jekyll::Hooks.register target, event, &method(action)
      end
    end
  end
end
