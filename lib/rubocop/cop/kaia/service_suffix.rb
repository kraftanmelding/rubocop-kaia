# frozen_string_literal: true

module RuboCop
  module Cop
    module Kaia
      class ServiceSuffix < Base
        MSG = 'Service classes should have a "Service" suffix.'

        def on_class(node)
          return unless service_class?(node)

          class_const = node.identifier
          class_name = class_const.source

          return if class_name.end_with?('Service')

          add_offense(class_const)
        end

        private

        def service_class?(node)
          parent_class = node.parent_class
          return false unless parent_class

          parent_name = parent_class.source

          parent_name.end_with?('Service')
        end
      end
    end
  end
end
