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
          begin
            do_something
            expensive_call
          end
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
          begin
            do_something
            expensive_call
          end
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
end
