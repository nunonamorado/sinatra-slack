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
          att_obj[:actions] = @actions unless @actions.empty?

          attrs = %i[title color attachment_type text fallback image_url]

          attrs.each do |a|
            a_value = send(a)
            next if !a_value || a_value.empty?

            att_obj[a] = a_value
          end

          att_obj
        end
      end
    end
  end
end
