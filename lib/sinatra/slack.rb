# frozen_string_literal: true

require 'sinatra/async'
require_relative './slack/instance_helpers'

# Sinatra
module Sinatra
  # Sinatra Module for creating Slack apps with ease
  module Slack
    def self.registered(app)
      app.register Sinatra::Async

      app.helpers Slack::InstanceHelpers
    end

    #  Defines a new before action for verifying all requests
    def verify_slack_request(secret)
      before do
        halt 401, 'Invalid Headers' unless authorized?(secret)
      end
    end

    # Defines a new HTTP POST Handler to receive
    # Slash Command notifications.
    def commands_endpoint(path, quick_reply: '')
      settings.apost(path) do
        signature = "#{command.command} #{command.text}"
        command_pattern = self.class.get_pattern(signature)

        halt 400 unless command_pattern

        request_handler = self.class.get_handler(signature)
        request_params = command_pattern.params(signature).values

        handle_request(request_handler, request_params, quick_reply)
      end
    end

    # Defines a new HTTP POST Handler to receive
    # Actions notifications.
    def actions_endpoint(path, quick_reply: '')
      settings.apost(path) do
        action_pattern = self.class.get_pattern(action.name)

        halt 400 unless action_pattern

        request_handler = self.class.get_handler(action.name)
        request_params = action_pattern.params(action.name).values || []
        request_params << action.value

        handle_request(request_handler, request_params, quick_reply)
      end
    end

    def register_handler(signature, &block)
      pattern = parse_signature(signature)
      method_name = get_handler_name(pattern)
      define_method(method_name, &block)
    end
    alias action register_handler
    alias command register_handler

    def get_handler(signature)
      pattern = get_pattern(signature)
      return unless pattern

      method_name = get_handler_name(pattern)
      instance_method method_name
    end

    def get_pattern(signature)
      @patterns.find { |p| p.match(signature) }
    end

    private

    def get_handler_name(pattern)
      "#{pattern.safe_string}_handler"
    end

    def parse_signature(signature)
      @patterns ||= []
      raise StandardError, 'Signature already defined' if get_pattern(signature)

      @patterns << Mustermann.new(signature)
      @patterns.last
    end
  end

  register Sinatra::Slack
end
