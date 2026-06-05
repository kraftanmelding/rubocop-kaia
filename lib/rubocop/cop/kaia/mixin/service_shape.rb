# frozen_string_literal: true

module RuboCop
  module Cop
    module Kaia
      # Shared helpers for the path-scoped service cops (`ServiceFileSuffix`,
      # `ServiceFileInheritance`).
      #
      # `app/services/` legitimately holds service-layer code that is not a
      # `.call`-style service object — query objects, presenters, pollers,
      # calculators, response builders. Flagging those for a "Service" suffix or
      # a "Service"-suffixed parent is a false positive. These helpers let the
      # cops fire only on classes that actually look like a service, so the
      # convention is enforced *when the service shape is chosen* rather than
      # demanded of every class under the directory.
      module ServiceShape
        # A class is "service-shaped" when any one of the following holds:
        #   * its name ends with `Service`;
        #   * it inherits from a `Service`-suffixed parent;
        #   * it defines a `call` or `self.call` entry point.
        def service_shaped?(class_node)
          service_suffixed_name?(class_node) ||
            service_suffixed_parent?(class_node) ||
            defines_call_entry_point?(class_node)
        end

        def service_suffixed_name?(class_node)
          class_node.identifier.source.end_with?('Service')
        end

        def service_suffixed_parent?(class_node)
          class_node.parent_class&.source&.end_with?('Service')
        end

        # Only definitions belonging to the class itself count — a `call`
        # defined inside a *nested class* must not mark the outer class as
        # service-shaped. Both `def self.call` and a `def call` inside a
        # `class << self` block are recognised as class-level entry points.
        def defines_call_entry_point?(class_node)
          top_level_nodes(class_node.body).any? { |child| call_definition?(child) }
        end

        def call_definition?(node)
          return false if node.nil?
          return true if (node.def_type? || node.defs_type?) && node.method_name == :call

          # `class << self; def call; end; end`
          node.sclass_type? && singleton_defines_call?(node)
        end

        def singleton_defines_call?(sclass_node)
          top_level_nodes(sclass_node.children[1]).any? do |child|
            child&.def_type? && child.method_name == :call
          end
        end

        # The direct children of a class/sclass body: nil, a single node, or
        # the children of a `begin` wrapper.
        def top_level_nodes(body)
          return [] if body.nil?

          body.begin_type? ? body.children : [body]
        end

        def in_services_directory?
          processed_source.path&.include?('app/services/')
        end

        def nested_class?(node)
          node.each_ancestor(:class).any?
        end
      end
    end
  end
end
