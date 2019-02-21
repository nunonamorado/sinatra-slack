module ResponseBlocks
  class Block
    attr_reader :type
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
      if val.responds_to?(:to_json)
        val.to_json
      elsif val.is_a? Enumerable
        val.map { |o| serialize_object(o) }
      else
        val
    end
  end
end
