# frozen_string_literal: true

module RuboCop
  module Cop
    module Kaia
      class ServiceFileInheritance < Base
        MSG = 'Classes defined in app/services must inherit from a "Service"-suffixed parent class.'

        def on_class(node)
          return unless in_services_directory?
          return if nested_class?(node)

          parent_class = node.parent_class
          return if parent_class&.source&.end_with?('Service')

          add_offense(node.identifier)
        end

        private

        def nested_class?(node)
          node.each_ancestor(:class).any?
        end

        def in_services_directory?
          path = processed_source.path
          path&.include?('app/services/')
        end
      end
    end
  end
end
