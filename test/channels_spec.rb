#! rspec
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


require_relative "spec_helper"

require "iochannel/channels"
require "iochannel/channel"

describe IOChannel::Channels do

  def bash_path
    IOChannel::Channels::BASH_SCR_PATH
  end

  describe ".allowed" do
    it "loads available channels on system" do
      bash_output = {
        "exit"   => 0,
        "stderr" => "",
        "stdout" => LSCSS_OUTPUT
      }
      expect(Yast::SCR).to receive(:Execute).
        with(bash_path, "lscss").
        and_return (bash_output)

      expect(IOChannel::Channels.allowed.size).to eq 1199
    end
  end

  describe "#block" do
    def channels(devices)
      channels = devices.map { |d| IOChannel::Channel.new d }
      channels = IOChannel::Channels.new channels
    end

    it "calls cio_ignore to block all included channels" do
      bash_output = {
        "exit"   => 0,
        "stderr" => "",
        "stdout" => ""
      }
      expect(Yast::SCR).to receive(:Execute).
        with(bash_path, "cio_ignore -a 0.0.0100,0.0.0200").
        once.
        and_return(bash_output)

      devices = ["0.0.0100","0.0.0200"]
      channels(devices).block
    end

    it "do nothing if there is no channel" do
      bash_output = {
        "exit"   => 0,
        "stderr" => "",
        "stdout" => ""
      }
      expect(Yast::SCR).to receive(:Execute).never

      channels([]).block
    end

    it "raise RuntimeError if cio_ignore failed" do
      bash_output = {
        "exit"   => 1,
        "stderr" => "Failed",
        "stdout" => ""
      }
      expect(Yast::SCR).to receive(:Execute).
        with(bash_path, "cio_ignore -a 0.0.0100,0.0.0200").
        once.
        and_return(bash_output)

      devices = ["0.0.0100","0.0.0200"]
      expect{channels(devices).block}.to raise_error(RuntimeError)
    end
  end

end
