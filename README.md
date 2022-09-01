# Sparkl

Sparkl provides a decorator-like way of writing hooks for your Rails controllers. Example:

```ruby
class MyController < ApplicationController
  extend Sparkl::Decoration

  def_decorator :special_auth, before_action: [:auth, if: -> { true or false }]

  special_auth def show
    # ... normal controller logic here
  end

  # instead of:
  # before_action :auth, only: [:show], if: -> { true or false }
end
```

Decorators can also be chained:

```ruby
class MyController < ApplicationController
  extend Sparkl::Decoration

  def_decorator :no_auth, skip_before_action: :authorize
  def_decorator :verify_scope, after_action: ->() {
    # ... logic to check policy scoping...
  }

  verify_scope no_auth def show
    # ... normal controller logic here
  end

  # or with parentheses:
  # verify_scope(
  #   no_auth(
  #     def show
  #       # ... normal controller logic here
  #     end
  #   )
  # )
end
```

and can also be reused:

```ruby
module MyActions
  extend Sparkl::Decorator

  def_decorator :redirect_if_true, before_action: [ :handle_redirect, { if: ->{ true } } ]

  private def handle_redirect
    redirect_to "..."
  end
end

class MyController < ApplicationController
  extend MyActions

  redirect_if_true def index
    # ...
  end
end
```

`def_decorator` is also aliased as `decorator`.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sparkl'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install sparkl

## Usage

See above for examples.

In the decorator definition, you define the moment the action will be performed - it can be
performed at multiple times if you like:

```ruby
decorator :foo, before_action: ->{ puts 'foo' }, after_action: ->{ puts :bar }
```

Available timings mirror Rails' own options:

```
before_action
prepend_before_action
after_action
prepend_after_action
skip_before_action
skip_after_action
```

Each action can take any of the arguments that a normal rails action would:

```ruby
decorator :foo, before_action: [:do_foo, if: :condition?]

# ...

# need to have do_foo and condition? methods defined
def do_foo
  # ...
end

def condition?
  true
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/johansenja/sparkl.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
