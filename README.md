# Sinatra::Slack

Creating your first Slack Slash Command application has never been to easy. With `sinatra-slack`

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sinatra-slack'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sinatra-slack

## Usage

``` ruby
require "sinatra/base"
require "sinatra/slack"

class App < Sinatra::Base
  register Sinatra::Security::SlackSignature
  register Sinatra::SlackCommands  
  register Sinatra::SlackActions  

  configure :production, :development do
    enable :logging
  end

  verify_slack_request secret: ENV["SLACK_SIGNING_SECRET"]
  commands_endpoint "/slack/commands"
  actions_endpoint "/slack/actions"

  command "/command *sub_command :spot_name" do |sub_command, spot_name|
    "Executed *command* command \n[subcommand]: #{sub_command} \n[args]:  #{spot_name}"
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nunonamorado/sinatra-slack. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Sinatra::Slack project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/sinatra-slack/blob/master/CODE_OF_CONDUCT.md).
