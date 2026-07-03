# frozen_string_literal: true

# Load rubocop-kaia Rake tasks in non-Rails projects.
#
# Add the following to your Rakefile:
#
#   require 'rubocop/kaia/rake_task'
#
load File.expand_path('../../tasks/rubocop_kaia.rake', __dir__)
