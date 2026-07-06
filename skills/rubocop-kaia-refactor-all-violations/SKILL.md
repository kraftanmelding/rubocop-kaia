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

**Skip previously attempted entries.** During parsing, skip any exclude line that has an
`# attempted` comment at the end of the line (outside the quoted file path — see below).
These are violations that failed in a previous run and should not be re-attempted.
Count these as `previously_attempted` for the summary.

**`# attempted` comment placement — critical.** The comment must go AFTER the closing quote
of the YAML string, NOT inside it:

```yaml
    # CORRECT — comment is after the closing quote:
    - "app/services/baz.rb"  # attempted
    - "app/services/qux.rb"  # attempted: external callers would break

    # WRONG — comment inside the string, breaks RuboCop parsing:
    - "app/services/baz.rb  # attempted"
```

When parsing, detect the comment by looking for `# attempted` after the closing quote on the line.
When writing, always append the comment after `"` (the closing quote).

**Coordinated refactoring.** When a file appears under both `Kaia/ServiceNoAddedPublicMethods`
and `Kaia/ServiceEntryPoint`, group them and handle them together. Services with multiple
public endpoints should be split into separate services (see the
[rubocop-kaia-refactor-service-no-added-public-methods skill](../rubocop-kaia-refactor-service-no-added-public-methods/SKILL.md),
step 5 "Handle genuine public endpoints"). Creating new service classes also resolves
`Kaia/ServiceEntryPoint` violations since callers must switch to `.call`.

### Step 2: Iterate Through Each Violation

For each `(cop_name, file_path)` pair:

#### 2.1 Identify Relevant Specs

Before making changes, find the specs that cover the file being refactored. These are the
specs that will be used to validate each change (the full suite runs in CI anyway). Use
these heuristics:

- Look for a matching spec file (e.g. `app/services/foo_service.rb` → `spec/services/foo_service_spec.rb`).
- Search for specs that reference the class name (e.g. `grep -rl 'FooService' spec/`).
- Include any request/integration specs that exercise the service's callers if renamed.
- Collect all matches into `${relevant_specs}` (space-separated list of spec files).

#### 2.2 Attempt RuboCop Autocorrection First

Try the built-in autocorrect before resorting to manual refactoring:

```sh
bundle exec rubocop -A --only ${cop_name} ${file_path}
```

Then validate:

```sh
bundle exec rubocop --only ${cop_name} ${file_path}
bundle exec rspec ${relevant_specs}
```

- **If autocorrection succeeded** (RuboCop passes, specs pass): skip to step 2.4 ("Handle the result — successful").
- **If autocorrection failed or left remaining offenses**: undo the autocorrect changes and proceed to step 2.3:
  ```sh
  git checkout -- ${file_path}
  ```

#### 2.3 Run the Cop-Specific Refactoring Skill

**Invoke the corresponding skill explicitly** — do not just infer the steps from memory.
Load the skill by name using the skill invocation mechanism (`$skill-name` or equivalent
in your environment). Map of cop to skill name:

| Cop | Skill name |
|---|---|
| `Kaia/ServiceEntryPoint` | `rubocop-kaia-refactor-service-entry-point` |
| `Kaia/ServiceFileInheritance` | `rubocop-kaia-refactor-service-file-inheritance` |
| `Kaia/ServiceFileSuffix` | `rubocop-kaia-refactor-service-file-suffix` |
| `Kaia/ServiceNoAddedClassMethods` | `rubocop-kaia-refactor-service-no-added-class-methods` |
| `Kaia/ServiceNoAddedPublicMethods` | `rubocop-kaia-refactor-service-no-added-public-methods` |
| `Kaia/ServiceSuffix` | `rubocop-kaia-refactor-service-suffix` |
| `Kaia/UseMemoWise` | `rubocop-kaia-refactor-use-memo-wise` |

The skill invocation should target the specific file `${file_path}`. The skill will
make changes to resolve the violation. After the skill completes, validate:

```sh
bundle exec rubocop --only ${cop_name} ${file_path}
bundle exec rspec ${relevant_specs}
```

#### 2.4 Handle the Result

**Commit discipline — one commit per file-cop combination.** Never commit changes to
multiple files in one commit. If the skill created new files (e.g. extracted a service),
those new files related to the same violation can be included.

**If successful** (RuboCop passes, relevant specs pass):
- Remove the file from the exclusion list for this cop in the exclusion file.
- Commit only the changes for this file:
  ```sh
  git add ${file_path}
  # plus any new files created as part of extraction (e.g. new service files)
  git commit -m "Refactor: fix ${cop_name} violation in ${file_path}"
  ```

**If failed** (specs break or refactoring is unclear):
- Revert all changes:
  ```sh
  git checkout -- ${file_path}
  ```
- Remove any new files that were created during the attempt.
- Mark the entry as attempted by appending `# attempted` **after the closing quote** to
  the exclude line in the exclusion file. If the reason is clear (e.g. "external callers
  would break"), append a brief explanation:
  ```yaml
  - "app/services/baz.rb"  # attempted: external callers would break
  ```
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
  Total violations in exclusion file: N
  Previously attempted (skipped): P
  Processed this run: M
    - Successfully refactored: X
      - via autocorrection: A
      - via skill-based refactoring: S
    - Failed this run: Y

  Successful:
    - Kaia/UseMemoWise in app/services/foo.rb (autocorrected)
    - Kaia/ServiceEntryPoint in app/services/bar.rb (skill-based)

  Failed:
    - Kaia/ServiceNoAddedClassMethods in app/services/baz.rb (reason: external callers)

  Previously attempted (not re-run):
    - Kaia/ServiceSuffix in app/services/legacy.rb
```
