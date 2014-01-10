#! rspec

require_relative "spec_helper"

require "iochannel/channels"
require "iochannel/channel"

describe IOChannel::Channels do

  def bash_path
    IOChannel::Channels::BASH_SCR_PATH
  end

  describe ".allowed" do
    LSCSS_OUTPUT = File.read(File.expand_path("../data/lscss.txt", __FILE__))

    it "loads available channels on system" do
      bash_output = {
        "exit"   => 0,
        "stderr" => "",
        "stdout" => LSCSS_OUTPUT
      }
      expect(Yast::SCR).to receive(:Execute).
        with(bash_path, "lscss").
        and_return (bash_output)

      expect(IOChannel::Channels.allowed.size).to be == 1199
    end
  end

  describe "#block" do
    def channels
      devices = ["0.0.0100","0.0.0200"]
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

      channels.block
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

      expect{channels.block}.to raise_error(RuntimeError)
    end
  end

end
