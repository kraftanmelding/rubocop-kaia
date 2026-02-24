# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = 'rubocop-kaia'
  spec.version = '0.1.0'
  spec.authors = ['Kaia']
  spec.summary = 'Custom RuboCop cops for Kaia projects'
  spec.description = 'A collection of custom RuboCop cops enforcing service class conventions.'

  spec.files = Dir['lib/**/*', 'config/**/*']
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 3.0'

  spec.add_dependency 'rubocop', '>= 1.0'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
