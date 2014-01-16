# Copyright (c) 2014 SUSE LLC.
#  All Rights Reserved.

#  This program is free software; you can redistribute it and/or
#  modify it under the terms of version 2 or 3 of the GNU General
# Public License as published by the Free Software Foundation.

#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.   See the
#  GNU General Public License for more details.

#  You should have received a copy of the GNU General Public License
#  along with this program; if not, contact SUSE LLC.

#  To contact Novell about this file by physical or electronic mail,
#  you may find current contact information at www.suse.com

module IOChannel
  class InvalidRangeValue < RuntimeError
    attr_reader :value

    def initialize value
      @value = value
      super "Invalid value '#{value}' passed as range"
    end
  end

  module ChannelRange

    class BaseValue

      def matching_channels
        raise "Internal Error: missing implementation"
      end

      protected
        def value_to_hex value
          value.delete(".").hex
        end

        def hex_to_value hex
          hex_s = hex.to_s(16)
          case hex_s.size
          when 1..4
            return "0.0.#{hex_s.rjust(4, "0")}"
          when 5
            return "0.#{hex_s[0]}.#{hex_s[1..4]}"
          when 6
            return "#{hex_s[0]}.#{hex_s[1]}.#{hex_s[2..5]}"
          else
            raise "Internal error: too big hex value"
          end
        end

        def initialize
        end
    end

    class SimpleValue < BaseValue
      def initialize value
        @value = value
      end

      def matching_channels
        [@value]
      end
    end

    class PartialValue < BaseValue
      def initialize value, initial
        value_s = value_to_hex(value).to_s(16)
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

    class RangeValue < BaseValue
      def initialize first, second
        @start = value_to_hex(ChannelRange.from_string(first).matching_channels.first)
        @end   = value_to_hex(ChannelRange.from_string(second, first).matching_channels.first)
      end

      def matching_channels
        (@start..@end).map { |hex| hex_to_value(hex) }
      end
    end

    class ListValue < BaseValue
      def initialize list
        @list = list.map{ |v| ChannelRange.from_string(v) }
      end

      def matching_channels
        @list.map(&:matching_channels).reduce(:+).uniq
      end
    end

    def self.from_string value, initial_hint = "0.0.0000"
      value.downcase!
      value.gsub!(/\s*/, "")
      case value
      when /,/
        ListValue.new value.split(",")
      when /\A([^-]+)-([^-]+)\z/
        RangeValue.new $1, $2
      when /\A\h\.\h\.\h{4}\z/
        SimpleValue.new value
      when /\A(\h\.)?\h{1,4}\z/
        PartialValue.new value, initial_hint
      else
        raise InvalidRangeValue.new(value)
      end
    end
  end
end
