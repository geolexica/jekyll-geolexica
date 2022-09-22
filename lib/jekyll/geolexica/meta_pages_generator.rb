# (c) Copyright 2020 Ribose Inc.
#

module Jekyll
  module Geolexica
    class MetaPagesGenerator < Generator
      include Configuration

      safe true

      attr_reader :generated_pages, :site

      # Generates Geolexica meta pages, both HTML and machine-readable.
      def generate(site)
        Jekyll.logger.info("Geolexica:", "Generating meta pages")

        # Jekyll does not say why it's a good idea, and whether such approach
        # is thread-safe or not, but most plugins in the wild do exactly that,
        # including these authored by Jekyll team.
        @site = site
        @generated_pages = []

        make_pages
        site.pages.concat(generated_pages)
      end

      # Processes concepts and yields a bunch of Jekyll::Page instances.
      def make_pages
        all_pages_pathnames.each do |p|
          next if skip_page?(p)
          add_page Page.new(site, base_dir, p.dirname.to_s, p.basename.to_s)
        end
      end

      # Lists all regular files in +base_dir+ recursively, and returns them
      # as an Array of Pathname instances, which are relative to +base_dir+.
      def all_pages_pathnames
        Dir.glob("**/*", base: base_dir).
          map { |path| Pathname.new(path) }.
          reject { |pathname| pathname.expand_path(base_dir).directory? }
      end

      def base_dir
        File.expand_path("../../../_pages", __dir__)
      end

      def skip_page?(pathname)
        (pathname.extname == ".ttl" && !output_turtle?) ||
        (pathname.extname == ".json" && !output_json?) ||
        false
      end

      def add_page *pages
        self.generated_pages.concat(pages)
      end
    end
  end
end
