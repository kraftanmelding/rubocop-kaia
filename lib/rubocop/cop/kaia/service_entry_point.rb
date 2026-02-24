# frozen_string_literal: true

module RuboCop
  module Cop
    module Kaia
      class ServiceEntryPoint < Base
        MSG = 'Service classes should only be called via .call'

        def on_send(node)
          return unless service_constant?(node.receiver)

          method_name = node.method_name
          return if method_name == :call

          add_offense(node)
        end

        private

        def service_constant?(node)
          return false unless node&.const_type?

          node.source.end_with?('Service')
        end
      end
    end
  end
end
