# frozen_string_literal: true

module Slack
  class ActionRequest
    attr_reader :name, :value

    def initialize(name, value, _body = nil)
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
