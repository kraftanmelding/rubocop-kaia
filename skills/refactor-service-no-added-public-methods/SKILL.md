---
name: refactor-service-no-added-public-methods
description: >-
  Refactors code violating the Kaia/ServiceNoAddedPublicMethods RuboCop cop. This cop enforces
  that only call and initialize can be public in service classes. Use when a *Service class
  exposes additional public instance methods.
---

## Cop Description

`Kaia/ServiceNoAddedPublicMethods` enforces that service classes (classes whose name ends with `Service`) only expose `call` and `initialize` as public methods. All other instance methods must be private or protected. This applies even when methods are wrapped (e.g., `memo_wise def foo`).

## Violation Examples

```ruby
# bad – public method other than call/initialize
class PaymentService < ApplicationService
  def call; end

  def validate_amount(amount)
    amount.positive?
  end
end

# bad – wrapped public method
class PaymentService < ApplicationService
  def call; end

  memo_wise def cached_rate
    ExchangeRate.fetch
  end
end
```

## Refactoring Process

1. **Identify the violation**: Find the public instance method(s) in the service class that are neither `call` nor `initialize`.

2. **Make the method private**: In most cases, the fix is simply to move the method under a `private` declaration:

   ```ruby
   # before
   class PaymentService < ApplicationService
     def call
       validate_amount(@amount)
     end

     def validate_amount(amount)
       amount.positive?
     end
   end

   # after
   class PaymentService < ApplicationService
     def call
       validate_amount(@amount)
     end

     private

     def validate_amount(amount)
       amount.positive?
     end
   end
   ```

3. **Handle wrapped methods** (e.g., `memo_wise def foo`): Move both the wrapper and the method under `private`:

   ```ruby
   # before
   memo_wise def cached_rate
     ExchangeRate.fetch
   end

   # after
   private

   memo_wise def cached_rate
     ExchangeRate.fetch
   end
   ```

4. **Check for external callers**: Before making a method private, search for external code that calls it:
   ```sh
   grep -rn "\.validate_amount" app/ spec/ --include="*.rb"
   ```
   If external code calls this method, either:
   - Inline the logic at the call site.
   - Extract it to a utility class or module that is not a service.
   - Expose it through the return value of `call`.

5. **Verify**: Run `bundle exec rubocop --only Kaia/ServiceNoAddedPublicMethods <file>` on each changed file. Run `bundle exec rspec` for affected specs.

## Result Handling

- **Success**: All refactored files pass RuboCop and RSpec. Accept the change and remove the file from the exclusion list (e.g., `.rubocop_custom_todo.yml`).
- **Failure**: The refactoring breaks tests in a way that is not obviously fixable. Skip the change and leave the violation in the exclusion list.
