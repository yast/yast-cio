#! rspec

require_relative "spec_helper"

require "iochannel/channels_dialog"

describe IOChannel::ChannelsDialog do
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

  def mock_dialog data={}
    data[:input] ||= :ok
    data[:filter] ||= ""

    data[:input] = [data[:input]] unless data[:input].is_a? Array

    ui = double("Yast::UI")
    stub_const("Yast::UI", ui)

    ui.should_receive(:OpenDialog).
      and_return(true)

    ui.should_receive(:CloseDialog).
      and_return(true)

    ui.should_receive(:UserInput).
      and_return(*data[:input])

    ui.should_receive(:QueryWidget).
      with(:filter_text, :Value).
      at_least(:once).
      and_return(data[:filter])
  end

  it "return :ok if user click on ok button" do
    mock_success_lscss
    mock_dialog :input => :ok

    expect(IOChannel::ChannelsDialog.run).to be == :ok
  end

  it "return :ok if user close window" do
    mock_success_lscss
    mock_dialog :input => :cancel

    expect(IOChannel::ChannelsDialog.run).to be == :ok
  end

  it "deselect all items in table after click on Clear Selection" do
    mock_success_lscss
    mock_dialog :input => [:clear, :ok]

    Yast::UI.should_receive(:ChangeWidget).
      with(:channels_table, :SelectedItems, [])

    IOChannel::ChannelsDialog.run
  end

  it "select all items in table after click on Select All" do
    mock_success_lscss
    mock_dialog :input => [:select_all, :ok]

    Yast::UI.should_receive(:ChangeWidget) do |id, attr, value|
      expect(id).to be == :channels_table
      expect(attr).to be == :SelectedItems
      expect(value.size).to be > 2 # non trivial size but do not tight it with test data
    end

    IOChannel::ChannelsDialog.run
  end

end
