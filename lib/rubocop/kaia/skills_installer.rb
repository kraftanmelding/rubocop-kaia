# frozen_string_literal: true

require 'fileutils'
require 'pathname'

module RuboCop
  module Kaia
    # Installs Claude skill symlinks from the gem into the consuming project.
    #
    # Each skill directory under the gem's `skills/` folder is symlinked into
    # the project's `.claude/skills/` directory, making them available for
    # Claude Code to discover automatically.
    module SkillsInstaller
      class << self
        # Installs skill symlinks into the given project directory.
        #
        # @param project_dir [String, Pathname] the root of the consuming project
        #   (defaults to the current working directory)
        # @return [Array<String>] list of skill names that were symlinked
        def install(project_dir: Dir.pwd)
          project_dir = Pathname.new(project_dir)
          target_dir = project_dir.join('.claude', 'skills')
          gem_skills_dir = gem_root.join('skills')

          return [] unless gem_skills_dir.directory?

          FileUtils.mkdir_p(target_dir)

          gem_skills_dir.children.select(&:directory?).sort.map do |skill_dir|
            link_path = target_dir.join(skill_dir.basename)
            create_symlink(skill_dir, link_path)
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

        def create_symlink(source, link_path)
          if link_path.symlink?
            # Update if pointing to a different target
            return if link_path.readlink == source

            link_path.delete
          elsif link_path.exist?
            # A real directory/file exists — don't overwrite
            return
          end

          FileUtils.ln_s(source.to_s, link_path.to_s)
        end
      end
    end
  end
end
