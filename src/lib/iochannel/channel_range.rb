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

    class PartialRange
      def initialize value, initial = "0.0.0000"
        value_hex = value.delete(".").hex
        value_s = value_hex.to_s(16)
        case value_s.size
        when 1..4
          # do nothing it is final format
        when 5
          value_s = "#{value_s[0]}.#{value_s[1..-1]}"
        else
          raise "Internal error: Invalid range size"
        end

        @value = initial[0..(-1-value_s.size)]+value_s
      end

      def matching_channels
        [@value]
      end
    end

    def self.from_string value
      case value
      when /\A\h\.\h\.\h{4}\z/
        SimpleRange.new value
      when /\A(\h\.)?\h{1,4}\z/
        PartialRange.new value
      else
        raise InvalidRangeValue.new(value)
      end
    end
  end
end
