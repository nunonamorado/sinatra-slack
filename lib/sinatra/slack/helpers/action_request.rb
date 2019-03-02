# frozen_string_literal: true

module Sinatra
  module Slack
    module Helpers
      # Representation of a Action request
      # sent from Slack Servers.
      class ActionRequest
        attr_reader :name, :value

        def initialize(name, value)
          @name = name
          @value = value
        end

        def self.parse(params)
          payload = JSON.parse params['payload']

          return unless payload['type'] == 'interactive_message'

          action = payload['actions'].first
          value = action['value'] if action.key?('value')
          value = action['selected_options'].first['value'] if action.key?('selected_options')
          name = payload['callback_id']

          new(name, value)
        end
      end
    end
  end
end
