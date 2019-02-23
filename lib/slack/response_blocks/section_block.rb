# frozen_string_literal: true

module Slack
  class SectionBlock < Block
    self.type = 'section'

    attr_accessor :text
    attr_reader :fields
    serialize_attributes :text, :fields, :accessory

    def field(element_type)
      field = Object.const_get(element_type)
      yield field if block_given?

      @fields ||= []
      @fields << field
    end

    def accessory(element_type)
      @accessory = Object.const_get(element_type)
      yield @accessory if block_given?
    end
  end
end
