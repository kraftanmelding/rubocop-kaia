# frozen_string_literal: true

begin
  require 'rails/railtie'

  module RuboCop
    module Kaia
      # Railtie that loads the rubocop_kaia:install_skills Rake task
      # automatically in Rails applications.
      class Railtie < ::Rails::Railtie
        rake_tasks do
          load File.expand_path('../../tasks/rubocop_kaia.rake', __dir__)
        end
      end
    end
  end
rescue LoadError, StandardError
  # Rails is not available or cannot initialize in this environment
  # (e.g., CI without a database, non-Rails projects).
  # The Railtie is skipped; rake tasks and other Rails-specific features
  # will not be registered.
end
