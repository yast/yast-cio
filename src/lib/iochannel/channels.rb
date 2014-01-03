require "forwardable"

require "yast/scr"
require "yast/path"

require "iochannel/channel"

module IOChannel
  class Channels
    extend Forwardable
    def_delegators :@channels, :size, :map

    BASH_SCR_PATH = Yast::Path.new(".target.bash_output")

    def initialize channels=[]
      @channels = channels
    end

    def select *args, &block
      Channels.new @channels.select(*args,&block)
    end

    def self.allowed
      result = Yast::SCR.Execute(BASH_SCR_PATH, "lscss")
      raise "Calling lscss failed with #{result["stderr"]}" unless result["exit"].zero?

      Channels.new parse_lscss_output(result["stdout"])
    end

    def block
      cmd = "cio_ignore -a #{@channels.map(&:device).join(",")}"

      result = Yast::SCR.Execute(BASH_SCR_PATH, cmd)
      raise "Calling cio_ignore failed with #{result["stderr"]}" unless result["exit"].zero?
    end

  private
    def self.parse_lscss_output output
      lines = output.split("\n")
      lines = lines[2..-1] #remove header and separator
      return [] unless lines

      lines.map do |line|
        device = line[/^[\h.]+/]
        used = line.include?("yes")
        Channel.new(device, used)
      end
    end
  end
end
