# frozen_string_literal: true

require 'rails/railtie'

module RuboCop
  module Kaia
    # Railtie that loads the rubocop_kaia:install_skills Rake task
    # automatically in Rails applications.
    class Railtie < ::Rails::Railtie
      rake_tasks do
        load File.expand_path('../tasks/rubocop_kaia.rake', __dir__)
      end
    end
  end
end
