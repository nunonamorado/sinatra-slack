# frozen_string_literal: true

module Slack
  class ImageBlock < Block
    self.type = 'image'

    attr_accessor :image_url, :alt_text, :title
    serialize_attributes :image_url, :alt_text, :title
  end
end
