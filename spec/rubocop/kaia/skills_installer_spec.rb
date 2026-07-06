# frozen_string_literal: true

require 'spec_helper'
require 'rubocop/kaia/skills_installer'
require 'tmpdir'

RSpec.describe RuboCop::Kaia::SkillsInstaller do
  let(:project_dir) { Pathname.new(Dir.mktmpdir) }

  after { FileUtils.rm_rf(project_dir) }

  describe '.gem_root' do
    it 'returns the gem root directory' do
      root = described_class.gem_root
      expect(root.join('skills')).to be_directory
      expect(root.join('lib', 'rubocop-kaia.rb')).to be_file
    end
  end

  describe '.install' do
    it 'creates .claude/skills directory and copies all skills' do
      installed = described_class.install(project_dir: project_dir)

      skills_dir = project_dir.join('.claude', 'skills')
      expect(skills_dir).to be_directory

      gem_skills = described_class.gem_root.join('skills').children.select(&:directory?).map { |d| d.basename.to_s }
      expect(installed).to match_array(gem_skills)

      installed.each do |skill_name|
        skill_dir = skills_dir.join(skill_name)
        expect(skill_dir).to be_directory
        expect(skill_dir).not_to be_symlink
        expect(skill_dir.join('SKILL.md')).to be_file
      end
    end

    it 'is idempotent — running twice does not raise' do
      described_class.install(project_dir: project_dir)
      result = described_class.install(project_dir: project_dir)

      expect(result).not_to be_empty

      skills_dir = project_dir.join('.claude', 'skills')
      result.each do |skill_name|
        skill_dir = skills_dir.join(skill_name)
        expect(skill_dir).to be_directory
        expect(skill_dir.join('SKILL.md')).to be_file
      end
    end

    it 'overwrites existing skill directories with fresh copies' do
      skills_dir = project_dir.join('.claude', 'skills')
      FileUtils.mkdir_p(skills_dir.join('rubocop-kaia-refactor-all-violations'))
      (skills_dir.join('rubocop-kaia-refactor-all-violations', 'stale-file.txt')).write('old content')

      described_class.install(project_dir: project_dir)

      skill_dir = skills_dir.join('rubocop-kaia-refactor-all-violations')
      expect(skill_dir).to be_directory
      expect(skill_dir).not_to be_symlink
      expect(skill_dir.join('SKILL.md')).to be_file
      expect(skill_dir.join('stale-file.txt')).not_to exist
    end
  end
end
