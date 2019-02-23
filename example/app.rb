# frozen_string_literal: true

require 'sinatra/base'
require_relative '../lib/sinatra/slack'

# Sinatra Slack Example Application
class App < Sinatra::Base
  register Sinatra::Slack

  configure :production, :development do
    enable :logging

    before { logger.info "Received: #{params}" }
  end

  verify_slack_request ENV['SLACK_SIGNING_SECRET']
  commands_endpoint '/slack/commands',
                    quick_reply: ':man-surfing: Fetching your report...'

  actions_endpoint '/slack/actions'

  command '/surf *sub_command :spot_name' do |sub_command, spot_name|
    slack_response "spot_info_#{sub_command}" do |r|
      r.text = "Executed command 'surf' with subcommand" \
               " '#{sub_command}' and spot_name: '#{spot_name}''"

      r.attachment do |a|
        a.fallback = 'This is a fallback'
        a.title = 'Please choose one from the following'

        3.times.each do |i|
          a.action_button 'surf_spot', "Choice #{i}", i.to_s
        end

        options = Array.new(5).map do |i|
          {
            text: "Tag#{i}",
            value: "tag#{i}"
          }
        end

        a.action_menu 'tag', 'Pick a tag', options
      end
    end
  end

  action 'spot_info(_:sub_command)?' do |sub_command, spot_id|
    slack_response "spot_info_#{sub_command}" do |r|
      r.text = "Executed action 'spot_info' with 'id' (#{sub_command})" \
                " and choice #{spot_id}"
    end
  end
end
