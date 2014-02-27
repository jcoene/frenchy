# Frenchy

Frenchy is a thing for turning HTTP JSON API endpoints into Rails-ish model objects. It deals with making requests, converting responses, type conversion, struct nesting, model decorating and instrumentation.

## Installation

Add this line to your application's Gemfile:

    gem "frenchy"

And then execute:

    $ bundle

## Usage

Frenchy supports multiple back-end services, you should register them in an initializer:

```ruby
# config/initializer/frenchy.rb
Frenchy.register_service :dodgeball, host: "http://127.0.0.1:3000"
```

Let's say we want to track the players on dodgeball team. Players have nicknames returned as a nested response:

```ruby
class Player
  # Include Frenchy::Model to get field macros and instance attribute methods
  include Frenchy::Model

  # Include Frenchy::Resource to get resource macro and class finder methods
  include Frenchy::Resource

  # Declare which service the model belongs to and specify your named API endpoints
  resource service: "dodgeball", endpoints: {
    one:  { path: "/v1/players/:id" },
    many: { path: "/v1/players", many: true },
    team: { path: "/v1/teams/:team_id/players", many: true }
  }

  # You can supply a primary key field, which really just uses it for to_param.
  key :id

  # Define fields which create named attributes and deal with typecasting.
  # Valid built-in types: string, integer, float, bool, time, array, hash
  field :id, type: "integer"
  field :name, type: "string"
  field :win_rate, type: "float"
  field :free_agent, type: "bool"

  # You can also supply types of any class that can be instantiated by sending
  # a hash of attributes to the "new" class method. If you specify the "many"
  # option, we'll expect that the server returns an array and will properly treat
  # the response as a collection.
  field :nicknames, type: "nickname", many: true
end

class Nickname
  include Frenchy::Model

  field :name, type: "string"
  field :insulting, type: "bool"
end

# GET /v1/players/1
# Expects response '{"id": N, ...}'
# Returns a single Player object
p = Player.find(1)

# GET /v1/players/?ids=1,2,3
# Expects response '[{"id": N, ...}, ...]'
# Returns multiple Player objects
Player.find_many([1,2,3])

# GET /v1/teams/3/players?injured=true
# Expects response '[{"id": N, ...}, ...]'
# Returns multiple Player objects
Player.find_with_endpoint(:team, team_id: 3, injured: true)
```

## Decorators

Frenchy loves decorating! Call the `.decorate` method on your Frenchy models for fun and profit. Under the covers it will find an appropriately named decorator (ex. `PlayerDecorator`) and call `decorate(self)` on it.

You can also call decorate on a collection of Frenchy models (as may be returned if you supply `many: true`).

## Instrumentation

Frenchy knows you like to monitor things, so requests are instrumented. You can do something like this:

```ruby
# in an initializer...

ActiveSupport::Notifications.subscribe /request.frenchy/ do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)

  # Generates something along the lines of:
  # [StatsD] dodgeball.player.one.count:1|c
  # [StatsD] dodgeball.player.one.runtime:528.78|c
  label = "#{event.payload[:service]}.#{event.payload[:model]}.#{event.payload[:endpoint]}"
  StatsD.increment "#{label}.count", 1
  StatsD.increment "#{label}.runtime", event.duration
end
```

Frenchy also provides Rails controller logging and instrumentation just like ActiveRecord:

```
Dodgeball (14.49ms) GET /v1/players/3
...
Completed 200 OK in 56.6ms (Views: 49.9ms | Frenchy: 14.49ms | ActiveRecord: 0.9ms)
```

## Mascot

![Frenchy](http://i.imgur.com/vQcCQfK.png)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

Copyright 2014 Jason Coene. Frenchy is released under the MIT license. See LICENSE.txt for details.
