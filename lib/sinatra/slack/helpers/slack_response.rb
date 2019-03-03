# frozen_string_literal: true

require_relative './slack_attachment'

module Sinatra
  module Slack
    module Helpers
      # Represents a message sent to the Slack Channel.
      class SlackResponse
        attr_accessor :text, :replace_original, :mrkdwn

        def initialize(callback_id)
          @callback_id = callback_id
          @text = nil
          @attachments = []
          @replace_original = true
          @mrkdwn = false
        end

        def attachment
          return unless block_given?

          attachment = Helpers::Attachment.new(@callback_id)
          yield attachment
          @attachments << attachment
        end

        def to_json
          response = {}

          response[:text] = @text if @text
          response[:mrkdwn] = @mrkdwn
          response[:replace_original] = @replace_original

          response[:attachments] = @attachments.map(&:to_json) unless @attachments.empty?

          response.to_json
        end
      end
    end
  end
end
