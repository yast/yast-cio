module IOChannel
  class InvalidRangeValue < RuntimeError
    attr_reader :value

    def initialize value
      @value = value
      super "Invalid value '#{value}' passed as range"
    end
  end

  module ChannelRange
    class SimpleRange
      def initialize value
        @value = value
      end

      def matching_channels
        [@value]
      end
    end

    def self.from_string value
      case value
      when /\A\h\.\h\.\h{4}\z/
        SimpleRange.new value
      else
        raise InvalidRangeValue.new(value)
      end
    end
  end
end
