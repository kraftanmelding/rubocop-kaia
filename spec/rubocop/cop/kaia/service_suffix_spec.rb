# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Kaia::ServiceSuffix, :config do
  let(:config) { RuboCop::Config.new }

  it 'registers an offense when class inherits from ApplicationService but does not end with Service' do
    expect_offense(<<~RUBY)
      class SomeLogic < ApplicationService
            ^^^^^^^^^ Kaia/ServiceSuffix: Service classes should have a "Service" suffix.
      end
    RUBY
  end

  it 'registers an offense when class inherits from a class ending in Service but does not end with Service' do
    expect_offense(<<~RUBY)
      class OtherLogic < BaseService
            ^^^^^^^^^^ Kaia/ServiceSuffix: Service classes should have a "Service" suffix.
      end
    RUBY
  end

  it 'does not register an offense when class inherits from ApplicationService and ends with Service' do
    expect_no_offenses(<<~RUBY)
      class MyCustomService < ApplicationService
      end
    RUBY
  end

  it 'does not register an offense when class inherits from a class ending in Service and ends with Service' do
    expect_no_offenses(<<~RUBY)
      class AnotherCustomService < BaseService
      end
    RUBY
  end

  it 'does not register an offense for unrelated inheritance' do
    expect_no_offenses(<<~RUBY)
      class SomeModel < ApplicationRecord
      end
    RUBY
  end

  it 'does not register an offense for module inclusion' do
    expect_no_offenses(<<~RUBY)
      class SomeClass
        include SomeModule
      end
    RUBY
  end

  it 'registers an offense for a namespaced service class without Service suffix' do
    expect_offense(<<~RUBY)
      module Billing
        class PaymentProcessor < Billing::BaseService
              ^^^^^^^^^^^^^^^^ Kaia/ServiceSuffix: Service classes should have a "Service" suffix.
        end
      end
    RUBY
  end

  it 'does not register an offense for a namespaced service class with Service suffix' do
    expect_no_offenses(<<~RUBY)
      module Billing
        class PaymentProcessingService < Billing::BaseService
        end
      end
    RUBY
  end
end
