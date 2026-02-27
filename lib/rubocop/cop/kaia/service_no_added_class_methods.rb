# frozen_string_literal: true

module RuboCop
  module Cop
    module Kaia
      class ServiceNoAddedClassMethods < Base
        MSG = 'Service classes should not define class methods.'

        def on_defs(node)
          return unless inside_service_class?(node)
          return if node.method_name == :call

          add_offense(node)
        end

        def on_sclass(node)
          return unless inside_service_class?(node)

          add_offense(node)
        end

        private

        def inside_service_class?(node)
          class_node = node.each_ancestor(:class).first
          return false unless class_node

          class_name = class_node.loc.name.source
          class_name.end_with?('Service')
        end
      end
    end
  end
end
