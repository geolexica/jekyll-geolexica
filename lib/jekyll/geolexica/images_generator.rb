# frozen_string_literal: true

# (c) Copyright 2020 Ribose Inc.
#

module Jekyll
  module Geolexica
    class ImagesGenerator < Generator
      include Configuration

      safe true

      attr_reader :generated_pages, :site

      def generate(site)
        Jekyll.logger.info("Geolexica:", "Generating concept images")

        # Jekyll does not say why it's a good idea, and whether such approach
        # is thread-safe or not, but most plugins in the wild do exactly that,
        # including these authored by Jekyll team.
        @site = site
        @generated_pages = []

        make_images if images_path && Dir.exist?(images_path)
        site.static_files.concat(generated_pages)
      end

      def make_images
        images_pathnames.each do |p|
          *base, dir = p.dirname.to_s.split("/")
          name = p.basename.to_s
          collection = Jekyll::Collection.new(site, "concepts")

          generated_pages << StaticFile.new(site, base, dir, name, collection)
        end
      end

      def images_pathnames
        Dir.glob("#{images_path}/*").map { |path| Pathname.new(path) }
      end
    end
  end
end
