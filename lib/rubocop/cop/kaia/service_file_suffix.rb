# frozen_string_literal: true

require_relative 'mixin/service_shape'

module RuboCop
  module Cop
    module Kaia
      class ServiceFileSuffix < Base
        include ServiceShape

        MSG = 'Classes defined in app/services must have a "Service" suffix.'

        def on_class(node)
          return unless in_services_directory?
          return if nested_class?(node)
          return unless service_shaped?(node)

          class_const = node.identifier
          return if class_const.source.end_with?('Service')

          add_offense(class_const)
        end
      end
    end
  end
end
