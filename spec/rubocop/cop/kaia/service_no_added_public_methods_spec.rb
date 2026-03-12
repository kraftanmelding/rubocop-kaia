# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Kaia::ServiceNoAddedPublicMethods, :config do
  let(:config) { RuboCop::Config.new }

  it 'registers an offense when a public instance method other than call is defined in a Service class' do
    expect_offense(<<~RUBY)
      class MyService
        def call
        end

        def perform
        ^^^^^^^^^^^ Kaia/ServiceNoAddedPublicMethods: Only `call` and `initialize` methods can be public in a Service class.
        end
      end
    RUBY
  end

  it 'does not register an offense for public call method in a Service class' do
    expect_no_offenses(<<~RUBY)
      class MyService
        def call
        end
      end
    RUBY
  end

  it 'does not register an offense for private methods in a Service class' do
    expect_no_offenses(<<~RUBY)
      class MyService
        def call
        end

        private

        def helper_method
        end
      end
    RUBY
  end

  it 'does not register an offense for protected methods in a Service class' do
    expect_no_offenses(<<~RUBY)
      class MyService
        protected

        def helper_method
        end
      end
    RUBY
  end

  it 'does not register an offense for methods in a non-Service class' do
    expect_no_offenses(<<~RUBY)
      class MyModel
        def public_method
        end
      end
    RUBY
  end

  it 'does not register an offense for public methods in a non-Service class if call is defined' do
    expect_no_offenses(<<~RUBY)
      class OtherJob
        def call
        end

        def perform
        end
      end
    RUBY
  end

  it 'handles multiple public methods in a Service class' do
    expect_offense(<<~RUBY)
      class TestService
        def method_one
        ^^^^^^^^^^^^^^ Kaia/ServiceNoAddedPublicMethods: Only `call` and `initialize` methods can be public in a Service class.
        end

        def method_two
        ^^^^^^^^^^^^^^ Kaia/ServiceNoAddedPublicMethods: Only `call` and `initialize` methods can be public in a Service class.
        end
      end
    RUBY
  end

  it 'does not register an offense for public initialize method in a Service class' do
    expect_no_offenses(<<~RUBY)
      class MyService
        def initialize(params)
          @params = params
        end

        def call
        end
      end
    RUBY
  end

  it 'does not register an offense for public methods in a nested class within a Service' do
    expect_no_offenses(<<~RUBY)
      class MyService
        class Error < StandardError
          def initialize(msg)
            super
          end

          def custom_public_method
          end
        end
      end
    RUBY
  end
end
