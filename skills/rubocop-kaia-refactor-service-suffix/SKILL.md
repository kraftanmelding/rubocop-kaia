---
name: rubocop-kaia-refactor-service-suffix
description: >-
  Refactors code violating the Kaia/ServiceSuffix RuboCop cop. This cop enforces that classes
  inheriting from a *Service parent must themselves end with "Service". Use when a class
  inherits from ApplicationService or similar but lacks the Service suffix.
---

## Cop Description

`Kaia/ServiceSuffix` enforces that any class inheriting from a `*Service` parent class must itself have a name ending with `Service`. This cop applies regardless of the file's location — it triggers whenever a class inherits from a service base class.

## Violation Examples

```ruby
# bad – inherits from ApplicationService but name doesn't end with "Service"
class PaymentProcessor < ApplicationService
  def call; end
end

# bad – inherits from BaseService
class Notifier < BaseService
  def call; end
end
```

## Refactoring Process

1. **Identify the violation**: Find the class that inherits from a `*Service` parent but whose own name does not end with `Service`.

2. **Rename the class**: Append `Service` to the class name (e.g., `PaymentProcessor` → `PaymentProcessorService`, `Notifier` → `NotifierService`).

3. **Rename the file**: If the file follows Rails naming conventions, rename it to match the new class name (e.g., `payment_processor.rb` → `payment_processor_service.rb`).

4. **Update all references**: Search the entire codebase for references to the old class name and update them:
   ```sh
   grep -rn "PaymentProcessor" app/ spec/ --include="*.rb"
   ```
   This includes:
   - Direct class references in other files.
   - Spec files (both the filename and class references inside).
   - Factory definitions, if any.
   - Route or configuration files, if any.
   - RuboCop exclusion lists or configuration files.

5. **Verify**: Run `bundle exec rubocop --only Kaia/ServiceSuffix <file>` on each changed file. Run `bundle exec rspec` for affected specs.

## Result Handling

- **Success**: All refactored files pass RuboCop and RSpec. Accept the change and remove the file from the exclusion list (e.g., `.rubocop_custom_todo.yml`).
- **Failure**: The refactoring breaks tests in a way that is not obviously fixable. Skip the change and leave the violation in the exclusion list.
