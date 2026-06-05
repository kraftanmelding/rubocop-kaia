# frozen_string_literal: true

require_relative 'mixin/service_shape'

module RuboCop
  module Cop
    module Kaia
      class ServiceFileInheritance < Base
        include ServiceShape

        MSG = 'Classes defined in app/services must inherit from a "Service"-suffixed parent class.'

        def on_class(node)
          return unless in_services_directory?
          return if nested_class?(node)
          return unless service_shaped?(node)

          parent_class = node.parent_class
          return if parent_class&.source&.end_with?('Service')

          add_offense(node.identifier)
        end
      end
    end
  end
end
