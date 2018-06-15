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
      call_ignore("-a")
    end

    def unblock
      call_ignore("-r")
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

    # number of entries that can fit into one command line run (see bsc#1096033)
    CHUNK_SIZE = 500

    def call_ignore(option)
      return if @channels.empty?

      # split channels into chunks, so it can run on cmdline
      # and then map it back chunk delimeter and index out of it
      channels_chunks = @channels.each_with_index.chunk{ |d, i| i/CHUNK_SIZE }
        .map { |i| i[1].map(&:first) }
      channels_chunks.each do |channels|
        cmd = "cio_ignore #{option} #{channels.map(&:device).join(",")}"

        result = Yast::SCR.Execute(BASH_SCR_PATH, cmd)
        raise "Calling cio_ignore failed with #{result["stderr"]}" unless result["exit"].zero?
      end
    end
  end
end
