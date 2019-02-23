# frozen_string_literal: true

module Slack
  class SlackResponse
    attr_accessor :text, :channel, :blocks, :mrkdwn

    def initialize
      @text = nil
      @channel = ''
      @mrkdwn = false
      @blocks = []
    end

    def section(&block)
      add_block(SectionBlock.new, &block)
    end

    def image(&block)
      add_block(ImageBlock.new, &block)
    end

    def divider
      add_block(Divider.new)
    end

    def actions(&block)
      add_block(ActionsBlock.new, &block)
    end

    def context(&block)
      add_block(ContextBlock.new, &block)
    end

    def to_json
      response = {}

      response[:text] = @text if @text
      response[:mrkdwn] = @mrkdwn
      response[:channel] = @channel unless @channel.empty?
      response[:blocks] = @blocks.map(&:to_json) unless @attachments.empty?

      response.to_json
    end

    private

    def add_block(msg_block)
      yield msg_block if block_given?
      @blocks << msg_block
    end
  end
end
