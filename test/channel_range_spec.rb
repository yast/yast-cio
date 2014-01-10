#! rspec

require_relative "spec_helper"

require "iochannel/channel_range"

describe IOChannel::ChannelRange do
  describe "#from_string" do
    it "returns range if simple channel passed" do
      range = IOChannel::ChannelRange.from_string "0.0.0100"
      expect(range.matching_channels).to eq ["0.0.0100"]
    end

    it "returns range if partial channel passed" do
      range = IOChannel::ChannelRange.from_string "100"
      expect(range.matching_channels).to eq ["0.0.0100"]
    end

    it "returns range if range of channels passed" do
      range = IOChannel::ChannelRange.from_string "0.0.0100-0.0.0102"
      expect(range.matching_channels).to eq ["0.0.0100","0.0.0101","0.0.0102"]
    end

    it "returns range if range of channels with partial part passed" do
      range = IOChannel::ChannelRange.from_string "0.0.0100-102"
      expect(range.matching_channels).to eq ["0.0.0100","0.0.0101","0.0.0102"]
      range = IOChannel::ChannelRange.from_string "100-102"
      expect(range.matching_channels).to eq ["0.0.0100","0.0.0101","0.0.0102"]
    end

    it "returns range if list of ranges passed" do
      range = IOChannel::ChannelRange.from_string "0.0.0100,50,0.0.0100-0.0.0102"
      expect(range.matching_channels).to match_array(["0.0.0100","0.0.0050","0.0.0101","0.0.0102"])
    end

    it "raises InvalidRangeValue exception if invalid range is passed" do
      expect{IOChannel::ChannelRange.from_string("invalid")}.to raise_error(IOChannel::InvalidRangeValue)
    end
  end
end
