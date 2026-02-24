# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Kaia::ServiceEntryPoint, :config do
  let(:config) { RuboCop::Config.new }

  it 'registers an offense when calling .new on a service class' do
    expect_offense(<<~RUBY)
      SomeService.new
      ^^^^^^^^^^^^^^^ Kaia/ServiceEntryPoint: Service classes should only be called via .call
    RUBY
  end

  it 'registers an offense when calling a random method on a service class' do
    expect_offense(<<~RUBY)
      SomeService.perform
      ^^^^^^^^^^^^^^^^^^^ Kaia/ServiceEntryPoint: Service classes should only be called via .call
    RUBY
  end

  it 'registers an offense when calling .new with arguments on a service class' do
    expect_offense(<<~RUBY)
      SomeService.new(arg: 1)
      ^^^^^^^^^^^^^^^^^^^^^^^ Kaia/ServiceEntryPoint: Service classes should only be called via .call
    RUBY
  end

  it 'does not register an offense when calling .call on a service class' do
    expect_no_offenses(<<~RUBY)
      SomeService.call
    RUBY
  end

  it 'does not register an offense when calling .call with arguments on a service class' do
    expect_no_offenses(<<~RUBY)
      SomeService.call(arg: 1)
    RUBY
  end

  it 'does not register an offense when calling .new on a non-service class' do
    expect_no_offenses(<<~RUBY)
      SomeModel.new
    RUBY
  end

  it 'registers an offense when calling .new chained with .call' do
    expect_offense(<<~RUBY)
      SomeService.new.call
      ^^^^^^^^^^^^^^^ Kaia/ServiceEntryPoint: Service classes should only be called via .call
    RUBY
  end

  it 'does not register an offense when calling a method on a non-constant receiver' do
    expect_no_offenses(<<~RUBY)
      service.call
    RUBY
  end
end
