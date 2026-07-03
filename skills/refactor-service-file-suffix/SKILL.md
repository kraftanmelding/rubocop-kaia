---
name: refactor-service-file-suffix
description: >-
  Refactors code violating the Kaia/ServiceFileSuffix RuboCop cop. This cop enforces that
  top-level classes in app/services/ have a name ending with "Service". Use when a class
  in the services directory is missing the Service suffix.
---

## Cop Description

`Kaia/ServiceFileSuffix` enforces that top-level classes defined in `app/services/` must have a name ending with `Service`. Nested classes inside a service are exempt.

## Violation Examples

```ruby
# bad – class in app/services/ without "Service" suffix
# app/services/payment_processor.rb
class PaymentProcessor
  def call; end
end
```

## Refactoring Process

1. **Identify the violation**: Find the class in `app/services/` whose name does not end with `Service`.

2. **Rename the class**: Append `Service` to the class name (e.g., `PaymentProcessor` → `PaymentProcessorService`).

3. **Rename the file**: Rename the file to match the new class name following Rails conventions (e.g., `payment_processor.rb` → `payment_processor_service.rb`).

4. **Update all references**: Search the entire codebase for references to the old class name and update them:
   ```sh
   grep -rn "PaymentProcessor" app/ spec/ --include="*.rb"
   ```
   This includes:
   - Direct class references in other files.
   - Spec files (both the filename and class references inside).
   - Factory definitions, if any.
   - Route or configuration files, if any.

5. **Verify**: Run `bundle exec rubocop --only Kaia/ServiceFileSuffix <file>` on each changed file. Run `bundle exec rspec` for affected specs.

## Result Handling

- **Success**: All refactored files pass RuboCop and RSpec. Accept the change and remove the file from the exclusion list (e.g., `.rubocop_custom_todo.yml`).
- **Failure**: The refactoring breaks tests in a way that is not obviously fixable. Skip the change and leave the violation in the exclusion list.
