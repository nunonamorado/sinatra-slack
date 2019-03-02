# frozen_string_literal: true

module Sinatra
  module Slack
    module Helpers
      # Represents a message attachment sent to the Slack Channel.
      class Attachment
        attr_accessor :title, :color, :attachment_type,
                      :text, :fallback, :image_url

        def initialize(callback_id)
          @callback_id = callback_id
          @attachment_type = 'default'
          @color = '#3AA3E3'
          @actions = []

          @text = ''
          @fallback = ''
          @image_url = ''
          @title = ''
        end

        def action_button(name, text, value)
          @actions << {
            name: name,
            text: text,
            type: 'button',
            value: value
          }
        end

        def action_menu(name, text, options)
          @actions << {
            name: name,
            text: text,
            type: 'select',
            options: options
          }
        end

        def to_json
          att_obj = {}

          att_obj[:callback_id] = @callback_id

          att_obj[:title] = title unless title.empty?
          att_obj[:color] = color unless color.empty?
          att_obj[:attachment_type] = attachment_type unless attachment_type.empty?
          att_obj[:text] = text unless text.empty?
          att_obj[:fallback] = fallback unless fallback.empty?
          att_obj[:image_url] = image_url unless image_url.empty?

          att_obj[:actions] = @actions unless @actions.empty?

          att_obj
        end
      end
    end
  end
end
