module ResponseBlocks
  class SectionBlock < Block
    self.type = "section"

    attr_accessor :text
    attr_reader :fields, :accessory
    serialize_attributes :text, :fields, :accessory

    def field(element_type, &block)
      field = Object.const_get(element_type)
      yield field if block_given?

      @fields ||= []
      @fields << field
    end

    def accessory(element_type, &block)
      @accessory = Object.const_get(element_type)
      yield @accessory if block_given?
    end
  end
end
