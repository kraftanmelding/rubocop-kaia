# frozen_string_literal: true

require 'rubocop'
require 'rubocop/rspec/support'
require 'rubocop-kaia'

RSpec.configure do |config|
  config.include RuboCop::RSpec::ExpectOffense
end
