# frozen_string_literal: true

module RuboCop
  module Cop
    module Kaia
      class ServiceNoAddedPublicMethods < Base
        include VisibilityHelp

        MSG = 'Only `call` and `initialize` methods can be public in a Service class.'

        def on_def(node)
          return unless inside_service_class?(node)
          return if node.method_name == :call
          return if node.method_name == :initialize
          return unless node_visibility(visibility_node(node)) == :public

          add_offense(node)
        end

        private

        # When a def is wrapped in a non-visibility send (e.g. `memo_wise def foo`),
        # the def node's parent is that send — not a visibility modifier — so the
        # normal left-sibling lookup finds nothing and defaults to :public.
        # Using the outer send as the anchor lets block-visibility (`private\n...`)
        # be detected correctly via its own left siblings.
        def visibility_node(node)
          parent = node.parent
          return node unless parent&.send_type? && !visibility_inline_on_def?(parent)

          parent
        end

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
