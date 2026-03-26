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
        extend AutoCorrector

        MSG = 'Use `memo_wise` instead of manually memoizing with instance variables.'

        # @!method or_asgn_ivar?(node)
        def_node_matcher :or_asgn_ivar?, <<~PATTERN
          (or_asgn (ivasgn _) _)
        PATTERN

        # @!method prepend_memo_wise?(node)
        def_node_matcher :prepend_memo_wise?, <<~PATTERN
          (send nil? :prepend (const nil? :MemoWise))
        PATTERN

        def on_new_investigation
          super
          @prepend_inserted_for = Set.new
        end

        def on_def(node)
          return if or_asgn_memoization?(node)

          defined_memoization?(node)
        end
        # Handle `def self.method` the same way; `register_offense` skips
        # auto-correction for `defs` nodes since MemoWise requires `class << self`.
        alias on_defs on_def

        private

        # Pattern: def method; @ivar ||= expr; end
        def or_asgn_memoization?(node)
          body = node.body
          return false unless body && or_asgn_ivar?(body)

          register_offense(node) do |corrector|
            corrector.insert_before(node.loc.keyword, 'memo_wise ')
            corrector.replace(body, unwrap_begin_source(body.children[1], body.loc.column))
            add_prepend_memo_wise(node, corrector)
          end
        end

        # Pattern: def method; return @ivar if defined?(@ivar); ...; @ivar = expr; end
        def defined_memoization?(node)
          body = node.body
          return false unless body&.begin_type?
          return false unless body.children.size >= 2

          guard = body.children.first
          assignment = body.children.last
          return false unless defined_guard?(guard) && assignment.ivasgn_type?
          return false unless matching_ivars?(guard, assignment)

          register_offense(node) do |corrector|
            corrector.insert_before(node.loc.keyword, 'memo_wise ')
            indent = ' ' * body.loc.column
            middle = body.children[1...-1].map(&:source)
            rhs = assignment.children[1]
            replacement = (middle + [unwrap_begin_source(rhs, body.loc.column)]).join("\n#{indent}")
            corrector.replace(body, replacement)
            add_prepend_memo_wise(node, corrector)
          end
        end

        # For `def self.method` (defs nodes), auto-correction is not possible
        # because `memo_wise def self.method` is not valid MemoWise syntax.
        # Class methods must be memoized inside a `class << self` block.
        def register_offense(node, &block)
          if node.defs_type?
            add_offense(node)
          else
            add_offense(node, &block)
          end
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

        def unwrap_begin_source(node, indent_width)
          if node.kwbegin_type?
            indent = ' ' * indent_width
            node.children.map(&:source).join("\n#{indent}")
          else
            node.source
          end
        end

        def add_prepend_memo_wise(def_node, corrector)
          class_node = def_node.each_ancestor(:sclass, :class, :module).first
          return unless class_node
          return if prepend_memo_wise_present?(class_node)

          return if @prepend_inserted_for.include?(class_node)

          @prepend_inserted_for.add(class_node)

          body = class_node.body
          indent = ' ' * body.loc.column
          corrector.insert_before(body, "prepend MemoWise\n\n#{indent}")
        end

        def prepend_memo_wise_present?(class_node)
          body = class_node.body
          return false unless body

          if body.begin_type?
            body.children.any? { |child| prepend_memo_wise?(child) }
          else
            prepend_memo_wise?(body)
          end
        end
      end
    end
  end
end
