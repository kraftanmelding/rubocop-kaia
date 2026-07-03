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

Read the exclusion file (default: `.rubocop_custom_todo.yml`). It typically has this structure:

```yaml
Kaia/ServiceEntryPoint:
  Exclude:
    - "app/services/payment_processor.rb"
    - "app/services/notification_sender.rb"

Kaia/ServiceSuffix:
  Exclude:
    - "app/services/payment_processor.rb"
```

Parse it into a list of `(cop_name, file_path)` pairs.

### Step 2: Iterate Through Each Violation

For each `(cop_name, file_path)` pair:

1. **Create a working state**: Note the current git state so changes can be reverted if needed:
   ```sh
   git stash push -m "before refactoring ${cop_name} in ${file_path}"
   ```

2. **Identify relevant specs**: Before making changes, find the specs that cover the file being
   refactored. These are the specs that will be used to validate each change (the full suite
   runs in CI anyway). Use these heuristics:
   - Look for a matching spec file (e.g. `app/services/foo_service.rb` → `spec/services/foo_service_spec.rb`).
   - Search for specs that reference the class name (e.g. `grep -rl 'FooService' spec/`).
   - Include any request/integration specs that exercise the service's callers if renamed.
   - Collect all matches into `${relevant_specs}` (space-separated list of spec files).

3. **Attempt RuboCop autocorrection first**: Try the built-in autocorrect before resorting to manual refactoring:
   ```sh
   bundle exec rubocop -A --only ${cop_name} ${file_path}
   ```

   Then validate:
   ```sh
   bundle exec rubocop --only ${cop_name} ${file_path}
   bundle exec rspec ${relevant_specs}
   ```

   - **If autocorrection succeeded** (RuboCop passes, specs pass): skip to step 5 ("Handle the result — successful").
   - **If autocorrection failed or left remaining offenses**: undo the autocorrect changes and proceed to step 4:
     ```sh
     git checkout -- .
     ```

4. **Run the cop-specific refactoring skill**: Apply the corresponding skill:
   - `Kaia/ServiceEntryPoint` → follow [rubocop-kaia-refactor-service-entry-point](../rubocop-kaia-refactor-service-entry-point/SKILL.md)
   - `Kaia/ServiceFileInheritance` → follow [rubocop-kaia-refactor-service-file-inheritance](../rubocop-kaia-refactor-service-file-inheritance/SKILL.md)
   - `Kaia/ServiceFileSuffix` → follow [rubocop-kaia-refactor-service-file-suffix](../rubocop-kaia-refactor-service-file-suffix/SKILL.md)
   - `Kaia/ServiceNoAddedClassMethods` → follow [rubocop-kaia-refactor-service-no-added-class-methods](../rubocop-kaia-refactor-service-no-added-class-methods/SKILL.md)
   - `Kaia/ServiceNoAddedPublicMethods` → follow [rubocop-kaia-refactor-service-no-added-public-methods](../rubocop-kaia-refactor-service-no-added-public-methods/SKILL.md)
   - `Kaia/ServiceSuffix` → follow [rubocop-kaia-refactor-service-suffix](../rubocop-kaia-refactor-service-suffix/SKILL.md)
   - `Kaia/UseMemoWise` → follow [rubocop-kaia-refactor-use-memo-wise](../rubocop-kaia-refactor-use-memo-wise/SKILL.md)

   Then validate:
   ```sh
   bundle exec rubocop --only ${cop_name} ${file_path}
   bundle exec rspec ${relevant_specs}
   ```

5. **Handle the result**:

   **If successful** (RuboCop passes, relevant specs pass):
   - Remove the file from the exclusion list for this cop in the exclusion file.
   - Commit the changes:
     ```sh
     git add -A
     git commit -m "Refactor: fix ${cop_name} violation in ${file_path}"
     ```

   **If failed** (specs break or refactoring is unclear):
   - Revert all changes:
     ```sh
     git checkout -- .
     git stash pop  # if stashed
     ```
   - Leave the entry in the exclusion list.
   - Log the failure and continue to the next violation.

### Step 3: Clean Up the Exclusion File

After processing all violations:

1. Remove any cop sections from the exclusion file that have an empty `Exclude` list.
2. If the exclusion file is completely empty, delete it and remove any `inherit_from` reference to it in `.rubocop.yml`.
3. Commit the final exclusion file cleanup:
   ```sh
   git add .rubocop_custom_todo.yml
   git commit -m "Clean up empty exclusions from .rubocop_custom_todo.yml"
   ```

### Step 4: Final Verification

Run the full suite one last time:
```sh
bundle exec rubocop
bundle exec rspec
```

## Summary Output

After completion, provide a summary:

```
Refactoring Summary:
  Total violations processed: N
  Successfully refactored: X
    - via autocorrection: A
    - via skill-based refactoring: S
  Skipped (failed): Y

  Successful:
    - Kaia/UseMemoWise in app/services/foo.rb (autocorrected)
    - Kaia/ServiceEntryPoint in app/services/bar.rb (skill-based)

  Skipped:
    - Kaia/ServiceNoAddedClassMethods in app/services/baz.rb (reason: external callers)
```
