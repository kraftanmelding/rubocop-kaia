# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Kaia::ServiceFileSuffix, :config do
  let(:config) { RuboCop::Config.new }

  it 'registers an offense when a class in app/services does not have a Service suffix' do
    expect_offense(<<~RUBY, 'app/services/payment_processor.rb')
      class PaymentProcessor < ApplicationService
            ^^^^^^^^^^^^^^^^ Kaia/ServiceFileSuffix: Classes defined in app/services must have a "Service" suffix.
      end
    RUBY
  end

  it 'registers an offense for a namespaced class in app/services without Service suffix' do
    expect_offense(<<~RUBY, 'app/services/billing/invoicer.rb')
      module Billing
        class Invoicer < ApplicationService
              ^^^^^^^^ Kaia/ServiceFileSuffix: Classes defined in app/services must have a "Service" suffix.
        end
      end
    RUBY
  end

  it 'does not register an offense when a class in app/services ends with Service' do
    expect_no_offenses(<<~RUBY, 'app/services/payment_processor_service.rb')
      class PaymentProcessorService < ApplicationService
      end
    RUBY
  end

  it 'does not register an offense for app/services/application_service.rb itself' do
    expect_no_offenses(<<~RUBY, 'app/services/application_service.rb')
      class ApplicationService
      end
    RUBY
  end

  it 'does not register an offense for a namespaced class in app/services with Service suffix' do
    expect_no_offenses(<<~RUBY, 'app/services/billing/invoicing_service.rb')
      module Billing
        class InvoicingService < ApplicationService
        end
      end
    RUBY
  end

  it 'does not register an offense for a class outside app/services' do
    expect_no_offenses(<<~RUBY, 'app/models/payment.rb')
      class Payment < ApplicationRecord
      end
    RUBY
  end

  it 'does not register an offense for a class in app/controllers' do
    expect_no_offenses(<<~RUBY, 'app/controllers/payments_controller.rb')
      class PaymentsController < ApplicationController
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

  it 'does not register an offense for a non-service-shaped class in app/services' do
    expect_no_offenses(<<~RUBY, 'app/services/statistics/yearly_data.rb')
      class Statistics::YearlyData
        def initialize(power_plant)
          @power_plant = power_plant
        end

        def volume
          @power_plant.volume
        end
      end
    RUBY
  end

  it 'registers an offense for a class with a call entry point but no Service suffix' do
    expect_offense(<<~RUBY, 'app/services/payment_processor.rb')
      class PaymentProcessor
            ^^^^^^^^^^^^^^^^ Kaia/ServiceFileSuffix: Classes defined in app/services must have a "Service" suffix.
        def call
          :done
        end
      end
    RUBY
  end

  it 'registers an offense for a class with a singleton-class call entry point but no Service suffix' do
    expect_offense(<<~RUBY, 'app/services/payment_processor.rb')
      class PaymentProcessor
            ^^^^^^^^^^^^^^^^ Kaia/ServiceFileSuffix: Classes defined in app/services must have a "Service" suffix.
        class << self
          def call
            :done
          end
        end
      end
    RUBY
  end

  it 'does not treat a call defined in a nested class as the outer class entry point' do
    expect_no_offenses(<<~RUBY, 'app/services/notification_core/dispatcher.rb')
      class NotificationCore::Dispatcher
        def dispatch(event)
          event
        end

        class Worker
          def call
            :done
          end
        end
      end
    RUBY
  end
end
