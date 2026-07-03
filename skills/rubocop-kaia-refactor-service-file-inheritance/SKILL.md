---
name: rubocop-kaia-refactor-service-file-inheritance
description: >-
  Refactors code violating the Kaia/ServiceFileInheritance RuboCop cop. This cop enforces that
  top-level classes in app/services/ inherit from a *Service parent class. Use when a service
  file class has no parent or inherits from a non-Service class.
---

## Cop Description

`Kaia/ServiceFileInheritance` enforces that top-level classes defined in `app/services/` must inherit from a parent class whose name ends with `Service` (e.g., `ApplicationService`, `BaseService`). Nested classes inside a service are exempt.

## Violation Examples

```ruby
# bad – no parent class
# app/services/my_service.rb
class MyService
  def call; end
end

# bad – parent class does not end with "Service"
# app/services/my_service.rb
class MyService < BaseClass
  def call; end
end
```

## Refactoring Process

1. **Identify the violation**: Find the class in `app/services/` that either has no parent class or inherits from a non-`*Service` class.

2. **Determine the correct parent class**: Check the project for an existing base service class (commonly `ApplicationService`, `BaseService`, or similar). Search with:
   ```sh
   grep -r "class.*Service" app/services/ | head -20
   ```

3. **Add or change the inheritance**:
   - If the class has no parent: add `< ApplicationService` (or the project's base service class).
   - If the class inherits from a non-Service class: change the parent to the appropriate `*Service` class.

4. **Ensure compatibility**: After changing the parent class, verify that:
   - The new parent class exists and is accessible.
   - The service class's `initialize` and `call` methods are compatible with the parent.
   - Any methods or callbacks from the previous parent (if any) are handled.

5. **Verify**: Run `bundle exec rubocop --only Kaia/ServiceFileInheritance <file>` on each changed file. Run `bundle exec rspec` for affected specs.

## Result Handling

- **Success**: All refactored files pass RuboCop and RSpec. Accept the change and remove the file from the exclusion list (e.g., `.rubocop_custom_todo.yml`).
- **Failure**: The refactoring breaks tests in a way that is not obviously fixable. Skip the change and leave the violation in the exclusion list.
