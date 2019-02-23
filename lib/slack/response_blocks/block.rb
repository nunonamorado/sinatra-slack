# frozen_string_literal: true

module Slack
  class Block
    attr_accessor :block_id

    def self.serialize_attributes(*attrs)
      @to_serialize = attrs
    end

    def type
      self.class.type
    end

    def to_json
      response = {}

      response[:type] = type
      response[:block_id] = block_id

      @to_serialize.each do |atr|
        response[atr] = serialize_object(send(atr))
      end

      response.to_json
    end

    private

    def serialize_object(obj)
      return obj.to_json if val.responds_to?(:to_json)

      return obj.map { |o| serialize_object(o) } if val.is_a? Enumerable

      obj
    end
  end
end
