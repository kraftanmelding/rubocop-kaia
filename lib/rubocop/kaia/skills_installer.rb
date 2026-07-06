# frozen_string_literal: true

require 'fileutils'
require 'pathname'

module RuboCop
  module Kaia
    # Installs Claude skill files from the gem into the consuming project.
    #
    # Each skill directory under the gem's `skills/` folder is copied into
    # the project's `.claude/skills/` directory, making them available for
    # Claude Code to discover automatically.
    module SkillsInstaller
      class << self
        # Installs skill directories into the given project directory.
        #
        # @param project_dir [String, Pathname] the root of the consuming project
        #   (defaults to the current working directory)
        # @return [Array<String>] list of skill names that were copied
        def install(project_dir: Dir.pwd)
          project_dir = Pathname.new(project_dir)
          target_dir = project_dir.join('.claude', 'skills')
          gem_skills_dir = gem_root.join('skills')

          return [] unless gem_skills_dir.directory?

          FileUtils.mkdir_p(target_dir)

          gem_skills_dir.children.select(&:directory?).sort.map do |skill_dir|
            copy_skill(skill_dir, target_dir)
            skill_dir.basename.to_s
          end
        end

        # Returns the root path of the installed gem.
        #
        # @return [Pathname]
        def gem_root
          Pathname.new(__dir__).join('..', '..', '..').expand_path
        end

        private

        def copy_skill(source, target_dir)
          dest = target_dir.join(source.basename)
          FileUtils.rm_rf(dest) if dest.exist?
          FileUtils.cp_r(source.to_s, dest.to_s)
        end
      end
    end
  end
end
