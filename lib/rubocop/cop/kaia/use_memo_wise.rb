# frozen_string_literal: true

module RuboCop
  module Cop
    module Kaia
      # Detects manual memoization patterns and suggests using `memo_wise` instead.
      #
      # @example
      #   # bad
      #   def method
      #     @ivar ||= expensive_call
      #   end
      #
      #   # bad
      #   def method
      #     return @ivar if defined?(@ivar)
      #     @ivar = expensive_call
      #   end
      #
      #   # good
      #   memo_wise def method
      #     expensive_call
      #   end
      class UseMemoWise < Base
        MSG = 'Use `memo_wise` instead of manually memoizing with instance variables.'

        # @!method or_asgn_ivar?(node)
        def_node_matcher :or_asgn_ivar?, <<~PATTERN
          (or_asgn (ivasgn _) _)
        PATTERN

        def on_def(node)
          return if or_asgn_memoization?(node)

          defined_memoization?(node)
        end

        private

        # Pattern: def method; @ivar ||= expr; end
        def or_asgn_memoization?(node)
          body = node.body
          return false unless body && or_asgn_ivar?(body)

          add_offense(node)
        end

        # Pattern: def method; return @ivar if defined?(@ivar); @ivar = expr; end
        def defined_memoization?(node)
          body = node.body
          return false unless body&.begin_type?
          return false unless body.children.size == 2

          guard, assignment = body.children
          return false unless defined_guard?(guard) && assignment.ivasgn_type?
          return false unless matching_ivars?(guard, assignment)

          add_offense(node)
        end

        def defined_guard?(node)
          return false unless node.if_type?

          condition = node.condition
          return false unless condition.defined_type?
          return false unless condition.children[0]&.ivar_type?

          if_branch = node.if_branch
          return false unless if_branch&.return_type?

          return_val = if_branch.children[0]
          return_val&.ivar_type?
        end

        def matching_ivars?(guard, assignment)
          guard_ivar = guard.condition.children[0].children[0]
          return_ivar = guard.if_branch.children[0].children[0]
          assign_ivar = assignment.children[0]

          guard_ivar == return_ivar && guard_ivar == assign_ivar
        end
      end
    end
  end
end
