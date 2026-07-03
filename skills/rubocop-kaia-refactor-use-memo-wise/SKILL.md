---
name: rubocop-kaia-refactor-use-memo-wise
description: >-
  Refactors code violating the Kaia/UseMemoWise RuboCop cop. This cop detects manual
  memoization patterns (@ivar ||= or defined?-guard) and enforces memo_wise instead.
  Use when a method uses manual instance variable memoization. Supports safe autocorrect.
---

## Cop Description

`Kaia/UseMemoWise` detects manual memoization patterns and enforces the use of the `memo_wise` gem instead. This cop has **safe autocorrect** enabled, so `rubocop -a` can fix most violations automatically.

### Detected Patterns

1. **Or-assign pattern**: `@ivar ||= expensive_call`
2. **Defined-guard pattern**: `return @ivar if defined?(@ivar); ...; @ivar = expensive_call`

## Violation Examples

```ruby
# bad – or-assign memoization
def total_price
  @total_price ||= items.sum(&:price)
end

# bad – defined-guard memoization
def current_user
  return @current_user if defined?(@current_user)
  @current_user = User.find(user_id)
end
```

## Refactoring Process

1. **Try autocorrect first**: Since this cop has safe autocorrect, run:
   ```sh
   bundle exec rubocop -a --only Kaia/UseMemoWise <file>
   ```
   This will automatically:
   - Remove the instance variable wrapper, leaving only the computation.
   - Add `memo_wise` before the `def` keyword (or `memo_wise :method_name` after for `def self.*` methods and delegate candidates).
   - Insert `prepend MemoWise` into the class/module body if not already present.

2. **Verify the autocorrect result**: Review the changes to ensure:
   - The `memo_wise` gem is in the project's `Gemfile`. If not, add it.
   - `prepend MemoWise` was inserted in the correct class or module.
   - For methods inside `included` blocks (concerns), the prepend is inside the block.

3. **Handle edge cases manually** (if autocorrect doesn't fully resolve):

   **Or-assign pattern:**
   ```ruby
   # before
   def total_price
     @total_price ||= items.sum(&:price)
   end

   # after
   memo_wise def total_price
     items.sum(&:price)
   end
   ```

   **Defined-guard pattern:**
   ```ruby
   # before
   def current_user
     return @current_user if defined?(@current_user)
     @current_user = User.find(user_id)
   end

   # after
   memo_wise def current_user
     User.find(user_id)
   end
   ```

   **Class method:**
   ```ruby
   # before
   def self.default_config
     @default_config ||= load_config
   end

   # after
   def self.default_config
     load_config
   end
   memo_wise self: :default_config
   ```

4. **Ensure MemoWise is prepended**: The class or module must include `prepend MemoWise`:
   ```ruby
   class MyService < ApplicationService
     prepend MemoWise

     memo_wise def total_price
       items.sum(&:price)
     end
   end
   ```

5. **Verify**: Run `bundle exec rubocop --only Kaia/UseMemoWise <file>` on each changed file. Run `bundle exec rspec` for affected specs.

## Result Handling

- **Success**: All refactored files pass RuboCop and RSpec. Accept the change and remove the file from the exclusion list (e.g., `.rubocop_custom_todo.yml`).
- **Failure**: The refactoring breaks tests in a way that is not obviously fixable. Skip the change and leave the violation in the exclusion list.
