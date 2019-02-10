require "sinatra/base"
require "httparty"

require_relative "../lib/sinatra/slack_commands"
require_relative "../lib/sinatra/slack_actions"
require_relative "../lib/sinatra/security/slack_signature"

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

  command "/surf *sub_command :spot_name" do |sub_command, spot_name|
    "Executed subcommand today with subcommand: #{sub_command} args:  #{spot_name}"
  end

  # action :action do |value|
  #   defer do
  #     spot_info = SurfForecaster.get_spot_info(value)
  #     result = SurfForecaster.get_spot_forecast(value, spot_info[:initstr])
  #     result.to_slack_response
  #   end

  #   200
  # end
end