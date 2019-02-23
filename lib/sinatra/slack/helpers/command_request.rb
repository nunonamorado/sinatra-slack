# frozen_string_literal: true

module Sinatra
  module Slack
    module Helpers
      class CommandRequest
        attr_reader :token, :command, :text, :response_url, :trigger_id,
                    :user_id, :user_name, :team_id, :team_name, :channel_id
        :channel_name

        def initialize(params = {})
          @params = params
          params.keys.each { |k| instance_variable_set("@#{k}", params[k]) }
        end

        def to_s
          @params.to_s
        end
      end
    end
  end
end
