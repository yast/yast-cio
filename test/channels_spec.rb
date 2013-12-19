#! rspec

$:.unshift(File.expand_path("../../src/lib", __FILE__))

require "iochannel/channels"

describe IOChannel::Channels do
  describe ".allowed" do
    LSCSS_OUTPUT = File.read(File.expand_path("../data/lscss.txt", __FILE__))

    it "loads available channels on system" do
      bash_output = {
        "exit"   => 0,
        "stderr" => "",
        "stdout" => LSCSS_OUTPUT
      }
      allow(Yast::SCR).to receive(:Execute).
        with(Yast::Path.new(".target.bash_output"), "lscss").
        and_return (bash_output)

      expect(IOChannel::Channels.allowed.size).to be == 1199
    end
  end
end
