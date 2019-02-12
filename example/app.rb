require "sinatra/base"
require_relative "../lib/sinatra/slack"

class App < Sinatra::Base
  register Sinatra::Slack::Signature
  register Sinatra::Slack::Commands  
  register Sinatra::Slack::Actions  

  configure :production, :development do
    enable :logging
  end

  verify_slack_request secret: ENV["SLACK_SIGNING_SECRET"]
  commands_endpoint "/slack/commands"
  actions_endpoint "/slack/actions"

  command "/surf *sub_command :spot_name" do |sub_command, spot_name|
    "Executed *surf* command \n[subcommand]: #{sub_command} \n[args]:  #{spot_name}"
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