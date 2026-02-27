# frozen_string_literal: true

module RuboCop
  module Cop
    module Kaia
      class ServiceNoAddedPublicMethods < Base
        include VisibilityHelp

        MSG = 'Only the `call` method can be public in a Service class.'

        def on_def(node)
          return unless inside_service_class?(node)
          return if node.method_name == :call
          return unless node_visibility(node) == :public

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
