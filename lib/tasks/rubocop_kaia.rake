# frozen_string_literal: true

require 'rubocop/kaia/skills_installer'

namespace :rubocop_kaia do
  desc 'Symlink rubocop-kaia Claude skills into .claude/skills/'
  task :install_skills do
    installed = RuboCop::Kaia::SkillsInstaller.install
    if installed.empty?
      puts 'rubocop-kaia: No skills found to install.'
    else
      puts "rubocop-kaia: Installed #{installed.size} skill(s) into .claude/skills/:"
      installed.each { |name| puts "  - #{name}" }
    end
  end
end
