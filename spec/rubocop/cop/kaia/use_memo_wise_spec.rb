# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Kaia::UseMemoWise, :config do
  let(:config) { RuboCop::Config.new }

  context 'when using ||= memoization pattern' do
    it 'registers an offense and corrects simple ||= memoization' do
      expect_offense(<<~RUBY)
        def method
        ^^^^^^^^^^ Kaia/UseMemoWise: Use `memo_wise` instead of manually memoizing with instance variables.
          @result ||= expensive_call
        end
      RUBY

      expect_correction(<<~RUBY)
        memo_wise def method
          expensive_call
        end
      RUBY
    end

    it 'registers an offense and corrects ||= memoization with complex expression' do
      expect_offense(<<~RUBY)
        def method
        ^^^^^^^^^^ Kaia/UseMemoWise: Use `memo_wise` instead of manually memoizing with instance variables.
          @result ||= SomeClass.new(arg1, arg2).process
        end
      RUBY

      expect_correction(<<~RUBY)
        memo_wise def method
          SomeClass.new(arg1, arg2).process
        end
      RUBY
    end

    it 'registers an offense and corrects ||= memoization with a block' do
      expect_offense(<<~RUBY)
        def method
        ^^^^^^^^^^ Kaia/UseMemoWise: Use `memo_wise` instead of manually memoizing with instance variables.
          @result ||= items.map { |item| item.name }
        end
      RUBY

      expect_correction(<<~RUBY)
        memo_wise def method
          items.map { |item| item.name }
        end
      RUBY
    end

    it 'registers an offense and corrects ||= memoization with arguments' do
      expect_offense(<<~RUBY)
        def method(arg)
        ^^^^^^^^^^^^^^^ Kaia/UseMemoWise: Use `memo_wise` instead of manually memoizing with instance variables.
          @result ||= expensive_call(arg)
        end
      RUBY

      expect_correction(<<~RUBY)
        memo_wise def method(arg)
          expensive_call(arg)
        end
      RUBY
    end

    it 'registers an offense and corrects ||= memoization with begin ... end block' do
      expect_offense(<<~RUBY)
        def method
        ^^^^^^^^^^ Kaia/UseMemoWise: Use `memo_wise` instead of manually memoizing with instance variables.
          @result ||= begin
            do_something
            expensive_call
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        memo_wise def method
          do_something
          expensive_call
        end
      RUBY
    end

    it 'registers an offense and corrects ||= memoization with case ... when ... end block' do
      expect_offense(<<~RUBY)
        def method
        ^^^^^^^^^^ Kaia/UseMemoWise: Use `memo_wise` instead of manually memoizing with instance variables.
          @result ||= case status
          when :active then do_active
          when :inactive then do_inactive
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        memo_wise def method
          case status
          when :active then do_active
          when :inactive then do_inactive
          end
        end
      RUBY
    end

    it 'registers an offense and corrects ||= memoization with if ... elsif ... else ... end block' do
      expect_offense(<<~RUBY)
        def method
        ^^^^^^^^^^ Kaia/UseMemoWise: Use `memo_wise` instead of manually memoizing with instance variables.
          @result ||= if condition_a
            do_a
          elsif condition_b
            do_b
          else
            do_c
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        memo_wise def method
          if condition_a
            do_a
          elsif condition_b
            do_b
          else
            do_c
          end
        end
      RUBY
    end
  end

  context 'when using defined? memoization pattern' do
    it 'registers an offense and corrects defined? guard with ivar assignment' do
      expect_offense(<<~RUBY)
        def method
        ^^^^^^^^^^ Kaia/UseMemoWise: Use `memo_wise` instead of manually memoizing with instance variables.
          return @result if defined?(@result)
          @result = expensive_call
        end
      RUBY

      expect_correction(<<~RUBY)
        memo_wise def method
          expensive_call
        end
      RUBY
    end

    it 'registers an offense and corrects defined? pattern with complex expression' do
      expect_offense(<<~RUBY)
        def method
        ^^^^^^^^^^ Kaia/UseMemoWise: Use `memo_wise` instead of manually memoizing with instance variables.
          return @data if defined?(@data)
          @data = SomeClass.new.fetch
        end
      RUBY

      expect_correction(<<~RUBY)
        memo_wise def method
          SomeClass.new.fetch
        end
      RUBY
    end

    it 'registers an offense and corrects defined? pattern with arguments' do
      expect_offense(<<~RUBY)
        def method(arg)
        ^^^^^^^^^^^^^^^ Kaia/UseMemoWise: Use `memo_wise` instead of manually memoizing with instance variables.
          return @result if defined?(@result)
          @result = expensive_call(arg)
        end
      RUBY

      expect_correction(<<~RUBY)
        memo_wise def method(arg)
          expensive_call(arg)
        end
      RUBY
    end

    it 'registers an offense and corrects defined? pattern with begin ... end block' do
      expect_offense(<<~RUBY)
        def method
        ^^^^^^^^^^ Kaia/UseMemoWise: Use `memo_wise` instead of manually memoizing with instance variables.
          return @result if defined?(@result)
          @result = begin
            do_something
            expensive_call
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        memo_wise def method
          do_something
          expensive_call
        end
      RUBY
    end

    it 'registers an offense and corrects defined? pattern with case ... when ... end block' do
      expect_offense(<<~RUBY)
        def method
        ^^^^^^^^^^ Kaia/UseMemoWise: Use `memo_wise` instead of manually memoizing with instance variables.
          return @result if defined?(@result)
          @result = case status
          when :active then do_active
          when :inactive then do_inactive
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        memo_wise def method
          case status
          when :active then do_active
          when :inactive then do_inactive
          end
        end
      RUBY
    end

    it 'registers an offense and corrects defined? pattern with if ... elsif ... else ... end block' do
      expect_offense(<<~RUBY)
        def method
        ^^^^^^^^^^ Kaia/UseMemoWise: Use `memo_wise` instead of manually memoizing with instance variables.
          return @result if defined?(@result)
          @result = if condition_a
            do_a
          elsif condition_b
            do_b
          else
            do_c
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        memo_wise def method
          if condition_a
            do_a
          elsif condition_b
            do_b
          else
            do_c
          end
        end
      RUBY
    end
  end

  context 'when not using memoization patterns' do
    it 'does not register an offense for a regular method' do
      expect_no_offenses(<<~RUBY)
        def method
          expensive_call
        end
      RUBY
    end

    it 'does not register an offense for a method using memo_wise' do
      expect_no_offenses(<<~RUBY)
        memo_wise def method
          expensive_call
        end
      RUBY
    end

    it 'does not register an offense for ||= with a local variable' do
      expect_no_offenses(<<~RUBY)
        def method
          result ||= expensive_call
        end
      RUBY
    end

    it 'does not register an offense for ivar assignment without memoization' do
      expect_no_offenses(<<~RUBY)
        def method
          @result = expensive_call
        end
      RUBY
    end

    it 'does not register an offense when defined? guard uses a different ivar than assignment' do
      expect_no_offenses(<<~RUBY)
        def method
          return @cached if defined?(@cached)
          @result = expensive_call
        end
      RUBY
    end

    it 'does not register an offense when defined? guard returns a different ivar' do
      expect_no_offenses(<<~RUBY)
        def method
          return @other if defined?(@result)
          @result = expensive_call
        end
      RUBY
    end

    it 'registers an offense and corrects a method with more than two statements' do
      expect_offense(<<~RUBY)
        def method
        ^^^^^^^^^^ Kaia/UseMemoWise: Use `memo_wise` instead of manually memoizing with instance variables.
          return @result if defined?(@result)
          setup_something
          @result = expensive_call
        end
      RUBY

      expect_correction(<<~RUBY)
        memo_wise def method
          setup_something
          expensive_call
        end
      RUBY
    end

    it 'does not register an offense for defined? without return' do
      expect_no_offenses(<<~RUBY)
        def method
          @result if defined?(@result)
          @result = expensive_call
        end
      RUBY
    end
  end

  context 'when adding prepend MemoWise' do
    it 'adds prepend MemoWise to a class for ||= pattern' do
      expect_offense(<<~RUBY)
        class MyClass
          def method
          ^^^^^^^^^^ Kaia/UseMemoWise: Use `memo_wise` instead of manually memoizing with instance variables.
            @result ||= expensive_call
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class MyClass
          prepend MemoWise

          memo_wise def method
            expensive_call
          end
        end
      RUBY
    end

    it 'adds prepend MemoWise to a class for defined? pattern' do
      expect_offense(<<~RUBY)
        class MyClass
          def method
          ^^^^^^^^^^ Kaia/UseMemoWise: Use `memo_wise` instead of manually memoizing with instance variables.
            return @result if defined?(@result)
            @result = expensive_call
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class MyClass
          prepend MemoWise

          memo_wise def method
            expensive_call
          end
        end
      RUBY
    end

    it 'adds prepend MemoWise to a module' do
      expect_offense(<<~RUBY)
        module MyModule
          def method
          ^^^^^^^^^^ Kaia/UseMemoWise: Use `memo_wise` instead of manually memoizing with instance variables.
            @result ||= expensive_call
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        module MyModule
          prepend MemoWise

          memo_wise def method
            expensive_call
          end
        end
      RUBY
    end

    it 'adds prepend MemoWise to a class with inheritance' do
      expect_offense(<<~RUBY)
        class MyClass < BaseClass
          def method
          ^^^^^^^^^^ Kaia/UseMemoWise: Use `memo_wise` instead of manually memoizing with instance variables.
            @result ||= expensive_call
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class MyClass < BaseClass
          prepend MemoWise

          memo_wise def method
            expensive_call
          end
        end
      RUBY
    end

    it 'does not add prepend MemoWise if already present' do
      expect_offense(<<~RUBY)
        class MyClass
          prepend MemoWise

          def method
          ^^^^^^^^^^ Kaia/UseMemoWise: Use `memo_wise` instead of manually memoizing with instance variables.
            @result ||= expensive_call
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class MyClass
          prepend MemoWise

          memo_wise def method
            expensive_call
          end
        end
      RUBY
    end

    it 'adds prepend MemoWise only once when correcting multiple methods in the same class' do
      expect_offense(<<~RUBY)
        class MyClass
          def method_a
          ^^^^^^^^^^^^ Kaia/UseMemoWise: Use `memo_wise` instead of manually memoizing with instance variables.
            @a ||= expensive_call_a
          end

          def method_b
          ^^^^^^^^^^^^ Kaia/UseMemoWise: Use `memo_wise` instead of manually memoizing with instance variables.
            @b ||= expensive_call_b
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class MyClass
          prepend MemoWise

          memo_wise def method_a
            expensive_call_a
          end

          memo_wise def method_b
            expensive_call_b
          end
        end
      RUBY
    end

    it 'adds prepend MemoWise to the innermost class in nested classes' do
      expect_offense(<<~RUBY)
        module Outer
          class Inner
            def method
            ^^^^^^^^^^ Kaia/UseMemoWise: Use `memo_wise` instead of manually memoizing with instance variables.
              @result ||= expensive_call
            end
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        module Outer
          class Inner
            prepend MemoWise

            memo_wise def method
              expensive_call
            end
          end
        end
      RUBY
    end
  end

  context 'when inside a concern module with included block' do
    context 'when method is outside included block' do
      it 'adds prepend MemoWise to the module scope' do
        expect_offense(<<~RUBY)
          module MyConcern
            extend ActiveSupport::Concern

            included do
              some_setup
            end

            def method
            ^^^^^^^^^^ Kaia/UseMemoWise: Use `memo_wise` instead of manually memoizing with instance variables.
              @result ||= expensive_call
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          module MyConcern
            prepend MemoWise

            extend ActiveSupport::Concern

            included do
              some_setup
            end

            memo_wise def method
              expensive_call
            end
          end
        RUBY
      end

      it 'adds prepend MemoWise to the module scope for defined? pattern' do
        expect_offense(<<~RUBY)
          module MyConcern
            extend ActiveSupport::Concern

            included do
              some_setup
            end

            def method
            ^^^^^^^^^^ Kaia/UseMemoWise: Use `memo_wise` instead of manually memoizing with instance variables.
              return @result if defined?(@result)
              @result = expensive_call
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          module MyConcern
            prepend MemoWise

            extend ActiveSupport::Concern

            included do
              some_setup
            end

            memo_wise def method
              expensive_call
            end
          end
        RUBY
      end

      it 'does not duplicate prepend MemoWise if already at module scope' do
        expect_offense(<<~RUBY)
          module MyConcern
            extend ActiveSupport::Concern
            prepend MemoWise

            included do
              some_setup
            end

            def method
            ^^^^^^^^^^ Kaia/UseMemoWise: Use `memo_wise` instead of manually memoizing with instance variables.
              @result ||= expensive_call
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          module MyConcern
            extend ActiveSupport::Concern
            prepend MemoWise

            included do
              some_setup
            end

            memo_wise def method
              expensive_call
            end
          end
        RUBY
      end

      it 'adds prepend MemoWise only once for multiple methods outside included' do
        expect_offense(<<~RUBY)
          module MyConcern
            extend ActiveSupport::Concern

            included do
              some_setup
            end

            def method_a
            ^^^^^^^^^^^^ Kaia/UseMemoWise: Use `memo_wise` instead of manually memoizing with instance variables.
              @a ||= expensive_call_a
            end

            def method_b
            ^^^^^^^^^^^^ Kaia/UseMemoWise: Use `memo_wise` instead of manually memoizing with instance variables.
              @b ||= expensive_call_b
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          module MyConcern
            prepend MemoWise

            extend ActiveSupport::Concern

            included do
              some_setup
            end

            memo_wise def method_a
              expensive_call_a
            end

            memo_wise def method_b
              expensive_call_b
            end
          end
        RUBY
      end
    end

    context 'when method is inside included block' do
      it 'adds prepend MemoWise inside the included block' do
        expect_offense(<<~RUBY)
          module MyConcern
            extend ActiveSupport::Concern

            included do
              some_setup

              def method
              ^^^^^^^^^^ Kaia/UseMemoWise: Use `memo_wise` instead of manually memoizing with instance variables.
                @result ||= expensive_call
              end
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          module MyConcern
            extend ActiveSupport::Concern

            included do
              prepend MemoWise

              some_setup

              memo_wise def method
                expensive_call
              end
            end
          end
        RUBY
      end

      it 'adds prepend MemoWise inside the included block for defined? pattern' do
        expect_offense(<<~RUBY)
          module MyConcern
            extend ActiveSupport::Concern

            included do
              some_setup

              def method
              ^^^^^^^^^^ Kaia/UseMemoWise: Use `memo_wise` instead of manually memoizing with instance variables.
                return @result if defined?(@result)
                @result = expensive_call
              end
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          module MyConcern
            extend ActiveSupport::Concern

            included do
              prepend MemoWise

              some_setup

              memo_wise def method
                expensive_call
              end
            end
          end
        RUBY
      end

      it 'does not duplicate prepend MemoWise if already inside included block' do
        expect_offense(<<~RUBY)
          module MyConcern
            extend ActiveSupport::Concern

            included do
              prepend MemoWise

              def method
              ^^^^^^^^^^ Kaia/UseMemoWise: Use `memo_wise` instead of manually memoizing with instance variables.
                @result ||= expensive_call
              end
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          module MyConcern
            extend ActiveSupport::Concern

            included do
              prepend MemoWise

              memo_wise def method
                expensive_call
              end
            end
          end
        RUBY
      end

      it 'adds prepend MemoWise only once for multiple methods inside included' do
        expect_offense(<<~RUBY)
          module MyConcern
            extend ActiveSupport::Concern

            included do
              some_setup

              def method_a
              ^^^^^^^^^^^^ Kaia/UseMemoWise: Use `memo_wise` instead of manually memoizing with instance variables.
                @a ||= expensive_call_a
              end

              def method_b
              ^^^^^^^^^^^^ Kaia/UseMemoWise: Use `memo_wise` instead of manually memoizing with instance variables.
                @b ||= expensive_call_b
              end
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          module MyConcern
            extend ActiveSupport::Concern

            included do
              prepend MemoWise

              some_setup

              memo_wise def method_a
                expensive_call_a
              end

              memo_wise def method_b
                expensive_call_b
              end
            end
          end
        RUBY
      end
    end

    context 'when methods are in both included block and module scope' do
      it 'adds prepend MemoWise to both locations' do
        expect_offense(<<~RUBY)
          module MyConcern
            extend ActiveSupport::Concern

            included do
              some_setup

              def included_method
              ^^^^^^^^^^^^^^^^^^^ Kaia/UseMemoWise: Use `memo_wise` instead of manually memoizing with instance variables.
                @a ||= expensive_call_a
              end
            end

            def module_method
            ^^^^^^^^^^^^^^^^^ Kaia/UseMemoWise: Use `memo_wise` instead of manually memoizing with instance variables.
              @b ||= expensive_call_b
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          module MyConcern
            prepend MemoWise

            extend ActiveSupport::Concern

            included do
              prepend MemoWise

              some_setup

              memo_wise def included_method
                expensive_call_a
              end
            end

            memo_wise def module_method
              expensive_call_b
            end
          end
        RUBY
      end
    end
  end

  context 'when using class method memoization with def self' do
    it 'registers an offense for def self.method with ||= but does not auto-correct' do
      expect_offense(<<~RUBY)
        class MyClass
          def self.method
          ^^^^^^^^^^^^^^^ Kaia/UseMemoWise: Use `memo_wise` instead of manually memoizing with instance variables.
            @result ||= expensive_call
          end
        end
      RUBY

      expect_no_corrections
    end

    it 'registers an offense for def self.method with defined? but does not auto-correct' do
      expect_offense(<<~RUBY)
        class MyClass
          def self.method
          ^^^^^^^^^^^^^^^ Kaia/UseMemoWise: Use `memo_wise` instead of manually memoizing with instance variables.
            return @result if defined?(@result)
            @result = expensive_call
          end
        end
      RUBY

      expect_no_corrections
    end

    it 'registers an offense for def self.method with arguments' do
      expect_offense(<<~RUBY)
        class MyClass
          def self.method(arg)
          ^^^^^^^^^^^^^^^^^^^^ Kaia/UseMemoWise: Use `memo_wise` instead of manually memoizing with instance variables.
            @result ||= expensive_call(arg)
          end
        end
      RUBY

      expect_no_corrections
    end

    it 'does not register an offense for def self.method without memoization' do
      expect_no_offenses(<<~RUBY)
        class MyClass
          def self.method
            expensive_call
          end
        end
      RUBY
    end
  end

  context 'when using class method memoization with class << self' do
    it 'registers an offense and corrects ||= inside class << self' do
      expect_offense(<<~RUBY)
        class MyClass
          class << self
            def method
            ^^^^^^^^^^ Kaia/UseMemoWise: Use `memo_wise` instead of manually memoizing with instance variables.
              @result ||= expensive_call
            end
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class MyClass
          class << self
            prepend MemoWise

            memo_wise def method
              expensive_call
            end
          end
        end
      RUBY
    end

    it 'registers an offense and corrects defined? pattern inside class << self' do
      expect_offense(<<~RUBY)
        class MyClass
          class << self
            def method
            ^^^^^^^^^^ Kaia/UseMemoWise: Use `memo_wise` instead of manually memoizing with instance variables.
              return @result if defined?(@result)
              @result = expensive_call
            end
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class MyClass
          class << self
            prepend MemoWise

            memo_wise def method
              expensive_call
            end
          end
        end
      RUBY
    end

    it 'does not duplicate prepend MemoWise inside class << self' do
      expect_offense(<<~RUBY)
        class MyClass
          class << self
            prepend MemoWise

            def method
            ^^^^^^^^^^ Kaia/UseMemoWise: Use `memo_wise` instead of manually memoizing with instance variables.
              @result ||= expensive_call
            end
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class MyClass
          class << self
            prepend MemoWise

            memo_wise def method
              expensive_call
            end
          end
        end
      RUBY
    end

    it 'does not register an offense for class << self without memoization' do
      expect_no_offenses(<<~RUBY)
        class MyClass
          class << self
            def method
              expensive_call
            end
          end
        end
      RUBY
    end

    it 'registers an offense and corrects ||= with arguments inside class << self' do
      expect_offense(<<~RUBY)
        class MyClass
          class << self
            def method(arg)
            ^^^^^^^^^^^^^^^ Kaia/UseMemoWise: Use `memo_wise` instead of manually memoizing with instance variables.
              @result ||= expensive_call(arg)
            end
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class MyClass
          class << self
            prepend MemoWise

            memo_wise def method(arg)
              expensive_call(arg)
            end
          end
        end
      RUBY
    end
  end
end
