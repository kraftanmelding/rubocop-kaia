# frozen_string_literal: true

module RuboCop
  module Cop
    module Kaia
      class ServiceFileSuffix < Base
        MSG = 'Classes defined in app/services must have a "Service" suffix.'

        def on_class(node)
          return unless in_services_directory?
          return if nested_class?(node)

          class_const = node.identifier
          class_name = class_const.source

          return if class_name.end_with?('Service')

          add_offense(class_const)
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
