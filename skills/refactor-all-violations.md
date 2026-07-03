# Skill: Refactor All Violations from Exclusion List

## Description

This skill cycles through a RuboCop exclusion list (e.g., `.rubocop_custom_todo.yml`) and attempts to refactor each violation into compliant code. Each successful refactoring is committed separately; failures are skipped and left in the exclusion list.

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

2. **Run the cop-specific refactoring skill**: Apply the corresponding skill:
   - `Kaia/ServiceEntryPoint` → follow `refactor-service-entry-point.md`
   - `Kaia/ServiceFileInheritance` → follow `refactor-service-file-inheritance.md`
   - `Kaia/ServiceFileSuffix` → follow `refactor-service-file-suffix.md`
   - `Kaia/ServiceNoAddedClassMethods` → follow `refactor-service-no-added-class-methods.md`
   - `Kaia/ServiceNoAddedPublicMethods` → follow `refactor-service-no-added-public-methods.md`
   - `Kaia/ServiceSuffix` → follow `refactor-service-suffix.md`
   - `Kaia/UseMemoWise` → follow `refactor-use-memo-wise.md`

3. **Validate the refactoring**:
   ```sh
   bundle exec rubocop --only ${cop_name} ${file_path}
   bundle exec rspec
   ```

4. **Handle the result**:

   **If successful** (RuboCop passes, RSpec passes):
   - Remove the file from the exclusion list for this cop in the exclusion file.
   - Commit the changes:
     ```sh
     git add -A
     git commit -m "Refactor: fix ${cop_name} violation in ${file_path}"
     ```

   **If failed** (tests break or refactoring is unclear):
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
  Skipped (failed): Y

  Successful:
    - Kaia/ServiceEntryPoint in app/services/foo.rb
    - Kaia/ServiceSuffix in app/services/bar.rb

  Skipped:
    - Kaia/ServiceNoAddedClassMethods in app/services/baz.rb (reason: external callers)
```
