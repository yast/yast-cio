#! rspec

require_relative "spec_helper"

require "iochannel/channels_dialog"

describe IOChannel::ChannelsDialog do
  describe ".run" do
    LSCSS_OUTPUT = File.read(File.expand_path("../data/lscss.txt", __FILE__))

    def mock_success_lscss
      bash_output = {
        "exit"   => 0,
        "stderr" => "",
        "stdout" => LSCSS_OUTPUT
      }
      allow(Yast::SCR).to receive(:Execute).
        with(Yast::Path.new(".target.bash_output"), "lscss").
        and_return (bash_output)
    end

    def mock_dialog_with_input(value)
      ui = double("Yast::UI")
      stub_const("Yast::UI", ui)

      ui.should_receive(:OpenDialog).
        and_return(true)

      ui.should_receive(:CloseDialog).
        and_return(true)

      ui.should_receive(:UserInput).
        and_return(value)
    end

    it "return :ok if user click on ok button" do
      mock_success_lscss
      mock_dialog_with_input :ok

      expect(IOChannel::ChannelsDialog.run).to be == :ok
    end

    it "return :cancel if user close window" do
      mock_success_lscss
      mock_dialog_with_input :cancel

      expect(IOChannel::ChannelsDialog.run).to be == :cancel
    end
  end
end
