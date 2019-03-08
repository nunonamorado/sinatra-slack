# Sinatra::Slack

> Note: WIP

Creating your first Slack Slash Command application has never been to easy. Combining `sinatra` and `sinatra-slack` DSL, you can quickly create a app that processes Slash Commands with ease.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sinatra-slack'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sinatra-slack

## Dependencies

This gem currently requires you to use [Thin](https://github.com/macournoyer/thin).

## Example

Go to folder example for more information. Learn how to create a Slack App in https://api.slack.com

## Usage

``` ruby
require "sinatra/base"
require "sinatra/slack"

class App < Sinatra::Base
  register Sinatra::Slack

  configure :production, :development do
    enable :logging

    before { logger.info "Received: #{params}" }
  end

  set :slack_secret, ENV['SLACK_SIGNING_SECRET']
  commands_endpoint "/slack/commands"
  actions_endpoint "/slack/actions"

  command "/command *sub_command :spot_name" do |sub_command, spot_name|
    "Executed *command* command \n[subcommand]: #{sub_command} \n[args]:  #{spot_name}"
  end
end
```

## TODO

- Adds specs;
- Update message helper to use the new [Block Kit](https://api.slack.com/reference/messaging/block-elements);
- Add more [Interactive Component Elements](https://api.slack.com/reference/messaging/interactive-components). Currently there is only support for *buttons* and *menu*.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nunonamorado/sinatra-slack. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
