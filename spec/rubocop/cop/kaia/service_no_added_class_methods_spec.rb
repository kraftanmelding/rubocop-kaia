# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Kaia::ServiceNoAddedClassMethods, :config do
  let(:config) { RuboCop::Config.new }

  it 'registers an offense when a class method with def self.name is defined in a Service class' do
    expect_offense(<<~RUBY)
      class MyService
        def self.helper
        ^^^^^^^^^^^^^^^ Kaia/ServiceNoAddedClassMethods: Service classes should not define class methods.
        end
      end
    RUBY
  end

  it 'registers an offense when a class method with class << self is defined in a Service class' do
    expect_offense(<<~RUBY)
      class MyService
        class << self
        ^^^^^^^^^^^^^ Kaia/ServiceNoAddedClassMethods: Service classes should not define class methods.
          def helper
          end
        end
      end
    RUBY
  end

  it 'does not register an offense for self.call in a Service class' do
    expect_no_offenses(<<~RUBY)
      class MyService
        def self.call
        end
      end
    RUBY
  end

  it 'does not register an offense for instance methods in a Service class' do
    expect_no_offenses(<<~RUBY)
      class MyService
        def call
        end

        private

        def helper
        end
      end
    RUBY
  end

  it 'does not register an offense for class methods in a non-Service class' do
    expect_no_offenses(<<~RUBY)
      class MyModel
        def self.find_by_id
        end

        class << self
          def helper
          end
        end
      end
    RUBY
  end

  it 'handles both class << self and def self.name in the same Service class' do
    expect_offense(<<~RUBY)
      class TestService
        def self.method_one
        ^^^^^^^^^^^^^^^^^^^ Kaia/ServiceNoAddedClassMethods: Service classes should not define class methods.
        end

        class << self
        ^^^^^^^^^^^^^ Kaia/ServiceNoAddedClassMethods: Service classes should not define class methods.
          def method_two
          end
        end
      end
    RUBY
  end

  it 'does not register an offense for class methods in a nested class within a Service' do
    expect_no_offenses(<<~RUBY)
      class MyService
        class Error < StandardError
          def self.custom_class_method
          end

          class << self
            def another_class_method
            end
          end
        end
      end
    RUBY
  end
end
