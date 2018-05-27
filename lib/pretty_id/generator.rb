module PrettyId
  class Generator
    attr_reader :record

    def initialize(record)
      @record = record
    end

    def id
      "#{prefix}_#{SecRandom.alphanumeric(length)}"
    end

    def length
      12
    end

    def prefix
      if record.class.id_prefix.is_a? Proc
        record.class.id_prefix.call(record)
      else
        record.class.id_prefix
      end
    end
  end
end
