require "sinatra/base"

require_relative "../lib/sinatra/slack"
require_relative "../lib/sinatra/security/slack_signature"

class App < Sinatra::Base
  register Sinatra::Slack
  register Sinatra::Security::SlackSignature

  configure :production, :development do
    enable :logging
  end

  #verify_slack_request ENV["SLACK_SIGNING_SECRET"]
  commands_endpoint "/slack/commands"
  actions_endpoint "/slack/actions"

  configure_command :stuff, arg1: String, arg2: Integer
  handle_command :stuff do |request|
    "Executed command stuff with args: #{request.args}"
  end


  configure_command :surf do |c|   
    c.with_subcommand :today, spot_name: String do |request|
      "Executed subcommand today with args: #{request.args}"  
    end

    c.with_subcommand :tomorrow, spot_name: String do |request|
      "Executed subcommand tomorrow with args: #{request.args}"  
    end

    c.with_subcommand :week, spot_name: String do |request|    
      "Executed subcommand week with args: #{request.args}"  
    end
  end

  # for_action :action do |value, ctx|
  #   ctx.defer do |channel|
  #     spot_info = SurfForecaster.get_spot_info(value)
  #     result = SurfForecaster.get_spot_forecast(value, spot_info[:initstr])
  #     channel.send(result.to_slack_response) 
  #   end

  #   200
  # end
end