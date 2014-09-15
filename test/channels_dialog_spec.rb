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
require_relative "yast_stubs"

describe "IOChannel::ChannelsDialog" do
  before :all do
    stub_yast_require
    require "iochannel/channels_dialog"
  end

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

    expect(ui).to receive(:OpenDialog).
      and_return(true)

    expect(ui).to receive(:CloseDialog).
      and_return(true)

    expect(ui).to receive(:UserInput).
      and_return(*data[:input])

    expect(ui).to receive(:QueryWidget).
      with(:filter_text, :Value).
      at_least(:once).
      and_return(data[:filter])
  end

  it "return :ok if user click on ok button" do
    mock_success_lscss
    mock_dialog :input => :ok

    expect(IOChannel::ChannelsDialog.run).to eq :ok
  end

  it "return :ok if user close window" do
    mock_success_lscss
    mock_dialog :input => :cancel

    expect(IOChannel::ChannelsDialog.run).to eq :ok
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
      expect(id).to eq :channels_table
      expect(attr).to eq :SelectedItems
      expect(value.size).to be > 2 # non trivial size but do not tight it with test data
    end

    IOChannel::ChannelsDialog.run
  end

end
