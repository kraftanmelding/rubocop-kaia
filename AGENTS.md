# AGENTS.md

Guidelines for AI agents working in this repository.

## Project overview

`rubocop-kaia` is a RuboCop extension gem that houses all custom RuboCop cops for Kaia projects. Currently it enforces service class conventions, but any future custom cops should be added here too. All cops live under `lib/rubocop/cop/kaia/` and are registered in `lib/rubocop-kaia.rb`.

## Repository layout

```txt
lib/
  rubocop-kaia.rb                        # Entry point — requires all cops
  rubocop/cop/kaia/
    service_entry_point.rb               # Kaia/ServiceEntryPoint cop
    service_file_inheritance.rb          # Kaia/ServiceFileInheritance cop
    service_file_suffix.rb               # Kaia/ServiceFileSuffix cop
    service_no_added_class_methods.rb    # Kaia/ServiceNoAddedClassMethods cop
    service_no_added_public_methods.rb   # Kaia/ServiceNoAddedPublicMethods cop
    service_suffix.rb                    # Kaia/ServiceSuffix cop
spec/rubocop/cop/kaia/
    service_entry_point_spec.rb
    service_file_inheritance_spec.rb
    service_file_suffix_spec.rb
    service_no_added_class_methods_spec.rb
    service_no_added_public_methods_spec.rb
    service_suffix_spec.rb
config/default.yml                       # Default enabled/disabled state for all cops
rubocop-kaia.gemspec
```

## Running tests

```sh
bundle exec rspec
```

Tests use `RuboCop::RSpec::ExpectOffense` helpers (`expect_offense` / `expect_no_offenses`). Always run the full suite before declaring a task done.

## Adding a new cop

1. Create `lib/rubocop/cop/kaia/<cop_name>.rb` inheriting from `RuboCop::Cop::Base`.
2. Add a `require_relative` line for it in `lib/rubocop-kaia.rb`.
3. Add a default entry in `config/default.yml` with at minimum `Enabled: true` and `Description`.
4. Create a matching spec at `spec/rubocop/cop/kaia/<cop_name>_spec.rb`. Cover both offending and non-offending cases.

## Code conventions

- All Ruby files start with `# frozen_string_literal: true`.
- Cops are namespaced under `RuboCop::Cop::Kaia`.
- Use `add_offense(node)` targeting the most specific node (e.g. `node.identifier` rather than `node`).
- No auto-correct (`SafeAutoCorrect: false`) unless the fix is unambiguous.
- Ruby >= 3.1 syntax is fine.

## What not to do

- Do not add runtime dependencies beyond `rubocop`.
- Do not modify `.github/workflows/ci.yml` Ruby version matrix without also verifying that the gem's `required_ruby_version` in the gemspec is consistent.
- Do not commit a gem version bump without a corresponding changelog entry (once one exists).
- Each commit must contain exactly one logical change. Do not bundle unrelated fixes or additions into a single commit.
