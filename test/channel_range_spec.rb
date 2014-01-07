#! rspec

require_relative "spec_helper"

require "iochannel/channel_range"

describe IOChannel::ChannelRange do
  describe "#from_string" do
    it "returns range if simple channel passed" do
      range = IOChannel::ChannelRange.from_string "0.0.0100"
      expect(range.matching_channels).to eq ["0.0.0100"]
    end

    it "raises InvalidRangeValue exception if invalid range is passed" do
      expect{IOChannel::ChannelRange.from_string("invalid")}.to raise_error(IOChannel::InvalidRangeValue)
    end
  end
end
