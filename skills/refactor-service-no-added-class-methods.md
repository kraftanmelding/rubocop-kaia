# Skill: Refactor Kaia/ServiceNoAddedClassMethods Violations

## Cop Description

`Kaia/ServiceNoAddedClassMethods` enforces that service classes (classes whose name ends with `Service`) must not define class methods other than `self.call`. Both `def self.method_name` and `class << self` blocks are flagged.

## Violation Examples

```ruby
# bad – class method other than self.call
class PaymentService < ApplicationService
  def self.default_currency
    "USD"
  end

  def call; end
end

# bad – class << self block
class PaymentService < ApplicationService
  class << self
    def default_currency
      "USD"
    end
  end

  def call; end
end
```

## Refactoring Process

1. **Identify the violation**: Find the class method(s) defined on the service class (other than `self.call`).

2. **Evaluate the class method's purpose**:
   - **Configuration/constants**: Convert to a constant or a private instance method.
   - **Factory or builder**: Move to a separate factory class or into `initialize`.
   - **Utility/helper**: Extract to a module, a plain Ruby class, or convert to a private instance method.

3. **Common refactoring patterns**:

   **Convert to a constant:**
   ```ruby
   # before
   def self.default_currency
     "USD"
   end

   # after
   DEFAULT_CURRENCY = "USD"
   ```

   **Convert to a private instance method:**
   ```ruby
   # before
   def self.max_retries
     3
   end

   # after
   private

   def max_retries
     3
   end
   ```

   **Extract to a separate class:**
   ```ruby
   # before (in PaymentService)
   def self.supported_methods
     %w[card bank_transfer]
   end

   # after (in a new class or module)
   module PaymentMethods
     SUPPORTED = %w[card bank_transfer].freeze
   end
   ```

4. **Update all call sites**: Search for references to the old class method and update:
   ```sh
   grep -rn "PaymentService\.default_currency" app/ spec/ --include="*.rb"
   ```

5. **Verify**: Run `bundle exec rubocop --only Kaia/ServiceNoAddedClassMethods <file>` on each changed file. Run `bundle exec rspec` for affected specs.

## Result Handling

- **Success**: All refactored files pass RuboCop and RSpec. Accept the change and remove the file from the exclusion list (e.g., `.rubocop_custom_todo.yml`).
- **Failure**: The refactoring breaks tests in a way that is not obviously fixable. Skip the change and leave the violation in the exclusion list.
