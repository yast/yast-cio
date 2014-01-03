module IOChannel
  class Channel < Struct.new(:device, :used)
    def initialize device, used = false
      raise "Each channel must have device" unless device

      super
    end

    alias_method :used?, :used
  end
end
