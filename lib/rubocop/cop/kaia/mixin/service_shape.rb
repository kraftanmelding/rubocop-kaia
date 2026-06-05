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

        # Only direct method definitions count — a `call` defined inside a
        # nested class must not mark the outer class as service-shaped.
        def defines_call_entry_point?(class_node)
          body = class_node.body
          return false unless body

          definitions = body.begin_type? ? body.children : [body]
          definitions.any? do |child|
            (child.def_type? || child.defs_type?) && child.method_name == :call
          end
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
