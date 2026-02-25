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

Classes defined under `app/services/` must end with `Service`.

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

## Requirements

- Ruby >= 3.1
- RuboCop >= 1.0

## Development

```sh
bundle install
bundle exec rspec
```

CI runs against Ruby 3.1, 3.2, and 3.3.

## License

See [LICENSE](LICENSE).
