# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Kaia::ServiceFileInheritance, :config do
  let(:config) { RuboCop::Config.new }

  it 'registers an offense when a class in app/services has no parent class' do
    expect_offense(<<~RUBY, 'app/services/payment_processor_service.rb')
      class PaymentProcessorService
            ^^^^^^^^^^^^^^^^^^^^^^^ Kaia/ServiceFileInheritance: Classes defined in app/services must inherit from a "Service"-suffixed parent class.
      end
    RUBY
  end

  it 'registers an offense when a class in app/services inherits from a non-Service parent' do
    expect_offense(<<~RUBY, 'app/services/payment_processor_service.rb')
      class PaymentProcessorService < ApplicationRecord
            ^^^^^^^^^^^^^^^^^^^^^^^ Kaia/ServiceFileInheritance: Classes defined in app/services must inherit from a "Service"-suffixed parent class.
      end
    RUBY
  end

  it 'does not register an offense when a class in app/services inherits from ApplicationService' do
    expect_no_offenses(<<~RUBY, 'app/services/payment_processor_service.rb')
      class PaymentProcessorService < ApplicationService
      end
    RUBY
  end

  it 'does not register an offense when a class in app/services inherits from any Service-suffixed parent' do
    expect_no_offenses(<<~RUBY, 'app/services/billing/invoicing_service.rb')
      class InvoicingService < Billing::BaseService
      end
    RUBY
  end

  it 'does not register an offense for a class outside app/services' do
    expect_no_offenses(<<~RUBY, 'app/models/payment.rb')
      class Payment < ApplicationRecord
      end
    RUBY
  end

  it 'registers an offense for a namespaced class in app/services with no parent' do
    expect_offense(<<~RUBY, 'app/services/elspot/bid_service.rb')
      module Elspot
        class BidService
              ^^^^^^^^^^ Kaia/ServiceFileInheritance: Classes defined in app/services must inherit from a "Service"-suffixed parent class.
        end
      end
    RUBY
  end

  it 'does not register an offense for a namespaced class in app/services inheriting from a Service parent' do
    expect_no_offenses(<<~RUBY, 'app/services/elspot/bid_service.rb')
      module Elspot
        class BidService < ApplicationService
        end
      end
    RUBY
  end

  it 'does not register an offense for a nested class inside a service class' do
    expect_no_offenses(<<~RUBY, 'app/services/payment_processor_service.rb')
      class PaymentProcessorService < ApplicationService
        class PaymentError < StandardError
        end
      end
    RUBY
  end
end
