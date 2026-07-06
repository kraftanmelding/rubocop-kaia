---
name: rubocop-kaia-refactor-service-entry-point
description: >-
  Refactors code violating the Kaia/ServiceEntryPoint RuboCop cop. This cop enforces that
  service classes are only invoked via .call. Use when a file is flagged for calling .new,
  .perform, or any method other than .call on a *Service class.
---

## Cop Description

`Kaia/ServiceEntryPoint` enforces that service classes (classes whose name ends with `Service`) are only invoked via `.call`. Direct use of `.new`, `.perform`, or any other class method is a violation.

## Violation Examples

```ruby
# bad – calling .new directly
result = MyService.new(params).call

# bad – calling a method other than .call
MyService.perform(params)

# bad – instantiating without .call
service = MyService.new(params)
```

## Refactoring Process

1. **Identify the violation**: Find the call site where a `*Service` class is invoked with a method other than `.call`.

2. **Refactor `.new(...).call` patterns**: If the code does `SomeService.new(args).call`, replace it with `SomeService.call(args)`. Ensure the service class accepts arguments through `initialize` and has a `call` instance method — the `self.call` class method (inherited from the base service class) should delegate to `.new(...).call`.

3. **Refactor `.new(...)` without `.call`**: If the code instantiates the service and stores it or chains other methods, restructure so the service is called via `.call` and returns the needed result.

4. **Refactor other method calls** (e.g., `.perform`, `.run`, `.execute`): Replace with `.call`. If the service class defines `self.perform` (or similar), rename that method to `call` inside the service class, and update all call sites.

5. **Verify**: Run `bundle exec rubocop --only Kaia/ServiceEntryPoint <file>` on each changed file. Run `bundle exec rspec` for affected specs.

## Result Handling

- **Success**: All refactored files pass RuboCop and RSpec. Accept the change and remove the file from the exclusion list (e.g., `.rubocop_custom_todo.yml`).
- **Failure**: The refactoring breaks tests in a way that is not obviously fixable. Skip the change and leave the violation in the exclusion list.
