# rubocop-kaia

Custom [RuboCop](https://rubocop.org/) cops enforcing service class conventions for Kaia projects.

## Installation

Add to your `Gemfile`:

```ruby
gem 'rubocop-kaia', require: false
```

Then add to your `.rubocop.yml`:

```yaml
inherit_gem:
  rubocop-kaia:
    - config/default.yml

require:
  - rubocop-kaia
```

`inherit_gem` loads the default configuration (all cops enabled). Without it, the cops are loaded but not active.

## Cops

All cops live under the `Kaia/` department.

### `Kaia/ServiceEntryPoint`

Service classes must only be called via `.call`. Calling `.new` or any other class method is an offense.

```ruby
# bad
SomeService.new
SomeService.new(arg: 1)
SomeService.perform

# good
SomeService.call
SomeService.call(arg: 1)
```

### `Kaia/ServiceSuffix`

Classes that inherit from a `*Service` parent must themselves end with `Service`.

```ruby
# bad
class PaymentProcessor < BaseService
end

# good
class PaymentProcessingService < BaseService
end
```

### `Kaia/ServiceFileSuffix`

Classes defined under `app/services/` must end with `Service`. Nested classes are exempt.

```ruby
# bad — in app/services/payment_processor.rb
class PaymentProcessor
end

# good — in app/services/payment_processing_service.rb
class PaymentProcessingService
end
```

### `Kaia/ServiceFileInheritance`

Top-level classes defined under `app/services/` must inherit from a `*Service`-suffixed parent class. Nested classes are exempt.

```ruby
# bad — in app/services/payment_processing_service.rb
class PaymentProcessingService
end

# good — in app/services/payment_processing_service.rb
class PaymentProcessingService < ApplicationService
end
```

### `Kaia/ServiceNoAddedPublicMethods`

Service classes can only have `call` as a public instance method. Any other public instance method is an offense. Private or protected methods are permitted. Nested classes inside the service are exempt from this rule.

```ruby
# bad
class PaymentProcessingService < ApplicationService
  def call; end
  def perform; end
end

# good
class PaymentProcessingService < ApplicationService
  def call; end

  private
  def helper; end
end
```

### `Kaia/ServiceNoAddedClassMethods`

Service classes must not define class methods. Any singleton class method (`def self.method`) or singleton class definition (`class << self`) is an offense. The only exception is `def self.call`, which is permitted. Nested classes inside the service are exempt.

```ruby
# bad
class PaymentProcessingService < ApplicationService
  def self.helper; end
  
  class << self
    def another_helper; end
  end
end

# good
class PaymentProcessingService < ApplicationService
  def self.call; end
  def call; end
end
```

### `Kaia/UseMemoWise`

Detects manual memoization patterns and suggests using `memo_wise` instead. Supports autocorrection for instance methods and `class << self` methods. `def self.method` patterns are flagged but not autocorrected (use `class << self` instead).

```ruby
# bad
def method
  @ivar ||= expensive_call
end

# bad
def method
  return @ivar if defined?(@ivar)
  @ivar = expensive_call
end

# good
memo_wise def method
  expensive_call
end
```

## Requirements

- Ruby >= 3.1
- RuboCop >= 1.0

## Development

```sh
bundle install
bundle exec rspec
```

CI runs against Ruby 3.1, 3.2, and 3.3.
