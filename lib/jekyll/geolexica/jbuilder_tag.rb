# (c) Copyright 2021 Ribose Inc.
#

# TODO: Extract that to a separate gem.

require "jbuilder"

module Jekyll
  module Geolexica
    class JbuilderTag < Liquid::Block
      def render(context)
        source = super
        wrapper = JbuilderWrapper.new(context)
        wrapper.eval_source(source)
        wrapper.target!
      rescue StandardError
        Jekyll.logger.error $!.detailed_message
        raise
      end

      # Instance of this class becomes +self+ in Jbuilder templates.
      # It provides access to Jbuilder instance and current Jekyll context
      # via +json+ and +context+ accessors, respectively.
      # There are convenient accessors to +site+ and +page+ Jekyll context
      # variables, too.
      #
      # @example
      #   # Should render {"time": "<time when site was generated>"}
      #   json.now context["site"]["time"]
      #   # Alternatively
      #   json.now site["time"]
      class JbuilderWrapper
        def initialize(context)
          @builder = Jbuilder.new
          @context = context
        end

        def json
          @builder
        end

        attr_reader :context

        def page
          @context["page"]
        end

        def site
          @context["site"]
        end

        def eval_source(source)
          instance_eval(source)
        rescue StandardError
          raise Error.new(source)
        end

        # This generates pretty output contrary to Jbuilder#target!.
        def target!
          JSON.pretty_generate(@builder.attributes!)
        end
      end

      class Error < StandardError
        attr_reader :template_body

        def initialize(template_body)
          @template_body = template_body.dup
        end

        def template_backtrace_location
          @template_backtrace_location ||=
            cause.backtrace_locations.detect { |bl| bl.path == "(eval)" }
        end

        # This is tricky!  The line number relates to the tag content,
        # not to the Liquid template.
        def template_lineno
          template_backtrace_location.lineno
        end

        def message
          "Error when processing Jbuilder template"
        end

        # Works only if error has been raised already (requires +#cause+
        # to be set).
        def detailed_message
          <<~MSG
            #{message}:

            #{location_surroundings}

            Caused by:
            #{cause.message}
          MSG
        end

        # Displays line that the error has occurred at.
        def location_surroundings(before: 2, after: 2)
          line_idx = template_lineno - 1 # template_lineno is indexed from 1

          before_lines = template_body.lines[line_idx - before, before]
          after_lines  = template_body.lines[line_idx + 1, after]
          that_line    = template_body.lines[line_idx]

          before_lines.each { |l| l.prepend("\s" * 4) }
          after_lines.each { |l| l.prepend("\s" * 4) }
          that_line.prepend("==> ")

          [*before_lines, that_line, *after_lines].join("")
        end
      end
    end
  end
end

Liquid::Template.register_tag("jbuilder", Jekyll::Geolexica::JbuilderTag)
