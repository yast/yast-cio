require "forwardable"

require "yast/scr"
require "yast/path"

require "iochannel/channel"

module IOChannel
  class Channels
    extend Forwardable
    BASH_SCR_PATH = Yast::Path.new(".target.bash_output")

    def initialize channels=[]
      @channels = channels
    end

    def self.allowed
      result = Yast::SCR.Execute(BASH_SCR_PATH, "lscss")
      raise "Calling lscss failed with #{result["stderr"]}" unless result["exit"].zero?

      Channels.new parse_lscss_output(result["stdout"])
    end

    def_delegators :@channels, :size, :map

  private
    def self.parse_lscss_output output
      lines = output.split("\n")
      lines = lines[2..-1] #remove header and separator
      return [] unless lines

      lines.map do |l|
        device = l[/^[\h.]+/]
        used = l.include?("yes")
        Channel.new(device, used)
      end
    end
  end
end
