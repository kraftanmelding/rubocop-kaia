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
    it 'creates .claude/skills directory and symlinks all skills' do
      installed = described_class.install(project_dir: project_dir)

      skills_dir = project_dir.join('.claude', 'skills')
      expect(skills_dir).to be_directory

      gem_skills = described_class.gem_root.join('skills').children.select(&:directory?).map { |d| d.basename.to_s }
      expect(installed).to match_array(gem_skills)

      installed.each do |skill_name|
        link = skills_dir.join(skill_name)
        expect(link).to be_symlink
        expect(link.readlink).to eq(described_class.gem_root.join('skills', skill_name))
      end
    end

    it 'is idempotent — running twice does not raise or duplicate' do
      described_class.install(project_dir: project_dir)
      result = described_class.install(project_dir: project_dir)

      expect(result).not_to be_empty

      skills_dir = project_dir.join('.claude', 'skills')
      result.each do |skill_name|
        link = skills_dir.join(skill_name)
        expect(link).to be_symlink
      end
    end

    it 'does not overwrite a real directory with the same name' do
      skills_dir = project_dir.join('.claude', 'skills')
      FileUtils.mkdir_p(skills_dir.join('refactor-all-violations'))
      (skills_dir.join('refactor-all-violations', 'custom-file.txt')).write('keep me')

      described_class.install(project_dir: project_dir)

      real_dir = skills_dir.join('refactor-all-violations')
      expect(real_dir).not_to be_symlink
      expect(real_dir.join('custom-file.txt').read).to eq('keep me')
    end

    it 'updates a stale symlink pointing to a different target' do
      skills_dir = project_dir.join('.claude', 'skills')
      FileUtils.mkdir_p(skills_dir)

      stale_target = Pathname.new(Dir.mktmpdir)
      FileUtils.ln_s(stale_target.to_s, skills_dir.join('refactor-all-violations').to_s)

      described_class.install(project_dir: project_dir)

      link = skills_dir.join('refactor-all-violations')
      expect(link).to be_symlink
      expect(link.readlink).to eq(described_class.gem_root.join('skills', 'refactor-all-violations'))

      FileUtils.rm_rf(stale_target)
    end
  end
end
