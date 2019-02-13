require "sinatra/base"
require "httparty"
require_relative "../lib/sinatra/slack"

class App < Sinatra::Base
  register Sinatra::Slack::Signature
  register Sinatra::Slack::Commands
  register Sinatra::Slack::Actions

  configure :production, :development do
    enable :logging
    set :threaded, false
  end

  verify_slack_request secret: ENV["SLACK_SIGNING_SECRET"]
  commands_endpoint "/slack/commands"
  actions_endpoint "/slack/actions"

  command "/surf *sub_command :spot_name" do |sub_command, spot_name|
    case sub_command
    when "tomorrow"
      EM.defer do
        send_to_channel(params["response_url"], sub_command, spot_name)
      end
      "Getting info..."
    else
      "Executed *surf* command \n[subcommand]: #{sub_command} \n[args]:  #{spot_name}"
    end
  end

  # action :action do |value|
  #   defer do
  #     spot_info = SurfForecaster.get_spot_info(value)
  #     result = SurfForecaster.get_spot_forecast(value, spot_info[:initstr])
  #     result.to_slack_response
  #   end

  #   200
  # end

  private

  def send_to_channel(url, *opts)
    options = {
      headers: {
        "Content-type": "application/json"
      },
      body: {
        text: "Sent after #{opts}"
      }.to_json
    }
    HTTParty.post(url, options)
  end
end
