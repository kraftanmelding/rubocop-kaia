---
name: rubocop-kaia-refactor-all-violations
description: >-
  Cycles through a RuboCop exclusion list (e.g. .rubocop_custom_todo.yml) and attempts to
  refactor each Kaia cop violation into compliant code. Each successful fix is committed
  separately; failures are skipped. Use when bulk-fixing Kaia cop violations from a todo file.
---

## Prerequisites

- The project has an exclusion file (e.g., `.rubocop_custom_todo.yml`) listing files excluded from specific Kaia cops.
- The project passes `bundle exec rspec` before starting.

## Process

### Step 1: Parse the Exclusion List

Read the exclusion file (default: `.rubocop_custom_todo.yml`). Build a set of ALL unique
service file paths mentioned across ALL Kaia cop sections. Process one service file at a
time, fixing all its violations together.

**Skip previously attempted entries.** For any exclude line with an `# attempted` comment,
skip that file entirely during parsing. These are violations that failed in a previous run
and should not be re-attempted.

**`# attempted` comment placement — critical.** The comment must go AFTER the closing
quote of the YAML string, NOT inside it:

```yaml
    # CORRECT — comment is after the closing quote:
    - "app/services/baz.rb"  # attempted
    - "app/services/qux.rb"  # attempted: external callers would break

    # WRONG — comment inside the string, breaks RuboCop parsing:
    - "app/services/baz.rb  # attempted"
```

### Step 2: Process Each Service File

For each unique service file in the exclusion set:

#### 2.0 Remove from ALL Exclusions

Remove the file from EVERY cop section in `.rubocop_custom_todo.yml`. Use `grep` to find
all occurrences:

```sh
grep -n "${filename}" .rubocop_custom_todo.yml
```

Then remove each line. If a cop section's `Exclude` list becomes empty, remove the entire
cop section. Update `# Offense count:` headers.

If the file was already fixed in a different cop section (still listed under others),
remove it from those remaining sections now.

#### 2.1 Run All Cops on the Service

```sh
bundle exec rubocop --only Kaia/ServiceEntryPoint,Kaia/ServiceFileInheritance,Kaia/ServiceFileSuffix,Kaia/ServiceNoAddedClassMethods,Kaia/ServiceNoAddedPublicMethods,Kaia/ServiceSuffix,Kaia/UseMemoWise ${file_path}
```

This shows ALL violations at once so you can fix them together.

#### 2.2 Identify Relevant Specs

- Look for a matching spec file (e.g. `app/services/foo_service.rb` → `spec/services/foo_service_spec.rb`).
- Search for specs that reference the class name (e.g. `grep -rn 'FooService' spec/`).
- Include any request/integration specs that exercise the service's callers if renamed.
- Include specs for all callers that will need updating.

#### 2.3 Attempt RuboCop Autocorrection First

```sh
bundle exec rubocop -A --only Kaia/ServiceEntryPoint,Kaia/ServiceFileInheritance,Kaia/ServiceFileSuffix,Kaia/ServiceNoAddedClassMethods,Kaia/ServiceNoAddedPublicMethods,Kaia/ServiceSuffix,Kaia/UseMemoWise ${file_path}
```

If autocorrect fixes everything, run specs and skip to step 2.5. If it fails, `git checkout -- ${file_path}` and proceed.

#### 2.4 Apply Cop-Specific Refactoring Skills

For EACH violation shown in step 2.1, **load and apply the corresponding skill**:

| Cop | Skill name |
|---|---|
| `Kaia/ServiceEntryPoint` | `rubocop-kaia-refactor-service-entry-point` |
| `Kaia/ServiceFileInheritance` | `rubocop-kaia-refactor-service-file-inheritance` |
| `Kaia/ServiceFileSuffix` | `rubocop-kaia-refactor-service-file-suffix` |
| `Kaia/ServiceNoAddedClassMethods` | `rubocop-kaia-refactor-service-no-added-class-methods` |
| `Kaia/ServiceNoAddedPublicMethods` | `rubocop-kaia-refactor-service-no-added-public-methods` |
| `Kaia/ServiceSuffix` | `rubocop-kaia-refactor-service-suffix` |
| `Kaia/UseMemoWise` | `rubocop-kaia-refactor-use-memo-wise` |

**Read the skill file fully before acting.** Do not infer steps from memory. Each skill
contains specific patterns the user approved.

**Universal patterns that satisfy multiple cops at once:**

- Inherit from `ApplicationService` (satisfies ServiceFileInheritance + ServiceEntryPoint
  via inherited `.call`)
- Convert `def self.method` to `def method` (instance method), add `initialize` to store
  args, add instance `call` with case/when dispatch (satisfies NoAddedClassMethods +
  NoAddedPublicMethods + ServiceEntryPoint)
- Rename file/class to end with `Service` (satisfies ServiceFileSuffix + ServiceSuffix)

#### 2.5 Verify EVERYTHING Locally

```sh
# 1. All Kaia cops pass on the service
bundle exec rubocop --only Kaia/ServiceEntryPoint,Kaia/ServiceFileInheritance,Kaia/ServiceFileSuffix,Kaia/ServiceNoAddedClassMethods,Kaia/ServiceNoAddedPublicMethods,Kaia/ServiceSuffix,Kaia/UseMemoWise ${file_path}

# 2. Full rubocop on all changed files
bundle exec rubocop

# 3. Run ALL relevant specs locally
bundle exec rspec ${relevant_specs}
```

**Never skip this step.** If either rubocop or specs fail, fix locally until both pass.
Do not push failures to CI.

#### 2.6 Handle the Result

**If successful** (all rubocop + all specs pass):
```sh
git add ${file_path} ${caller_files} .rubocop_custom_todo.yml
git commit -m "Refactor: fix all Kaia cop violations for ${file_path}"
git push
```

**If failed** (specs break or some cop cannot be resolved):
- `git checkout --` to revert ALL changes.
- Re-add the file to ALL cop sections it was removed from, with `# attempted: <reason>`
  comments explaining WHICH cop-specific skills were tried and WHY they failed.
- Do NOT add `# attempted` without genuinely trying each relevant cop skill.

#### 2.7 Proceed to Next Service

Go back to step 2.0 for the next service file.

### Step 3: Final Cleanup

Remove any empty cop sections. Run `bundle exec rubocop` to verify zero Kaia offenses.
Commit cleanup separately.

## Hard Rules (Never Violate)

1. **Service-by-service**: Remove a file from ALL exclusions at once, fix everything
   together. Never half-fix a service.
2. **Read skills**: Always `read_file` the cop-specific skill before applying it.
   Never infer steps from memory.
3. **No blind #attempted**: Only mark as attempted after genuinely loading and trying
   every applicable cop-specific skill.
4. **No self.call on ApplicationService children**: `ApplicationService` provides
   `def self.call(...) = new(...).call`. Children inherit it. Define only `initialize`
   and instance `call`.
5. **No send**: Use explicit `case @operation / when :x then x / end` dispatch.
   Raw `send(@operation)` is prohibited.
6. **Verify locally before EVERY push**: 
   ```sh
   bundle exec rubocop --no-server          # must return "no offenses detected"
   ruby -e 'require "yaml"; YAML.safe_load(File.read(".rubocop_custom_todo.yml"))'  # must return no error
   ```
   Run `rspec` on ALL changed spec files. Fix every failure before pushing.
   Never rely on CI to find test failures — CI is for final verification only.
7. **Never --no-verify**: If overcommit loops, `rubocop -A` manually, `git add`,
   then commit.
8. **I18n in specs**: Use `around { |example| I18n.with_locale(:en) { example.run } }`
   instead of `before { I18n.locale = :en }`.

## Summary Output Format

```
Refactoring Summary:
  Services processed: N
  Successfully refactored: X
  Failed (attempted): Y
  Previously attempted (skipped): P

  Successful:
    - app/services/foo_service.rb
    - app/services/bar_service.rb

  Attempted:
    - app/services/baz_service.rb (reason: payment calculation method used
      by AR callbacks, cannot be made private)
    - app/services/qux_service.rb (reason: external callers in 15 controllers
      would break, needs coordinated rollout)

  Skipped (previously attempted):
    - app/services/legacy_service.rb
```
