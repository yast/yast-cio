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

require "iochannel/channel_range"

describe IOChannel::ChannelRange do
  describe "#from_string" do
    it "returns range if simple channel passed" do
      range = IOChannel::ChannelRange.from_string "0.0.0100"
      expect(range.matching_channels).to eq ["0.0.0100"]
    end

    it "is not case sensitive" do
      range = IOChannel::ChannelRange.from_string "0.0.0aAf"
      expect(range.matching_channels).to eq ["0.0.0aaf"]
    end

    it "ignores all spaces" do
      range = IOChannel::ChannelRange.from_string "0.0.0001, 0.0.0002"
      expect(range.matching_channels).to match_array(["0.0.0001","0.0.0002"])
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
      range = IOChannel::ChannelRange.from_string "0.0.0100-2"
      expect(range.matching_channels).to eq ["0.0.0100","0.0.0101","0.0.0102"]
      range = IOChannel::ChannelRange.from_string "100-102"
      expect(range.matching_channels).to eq ["0.0.0100","0.0.0101","0.0.0102"]
    end

    it "returns range if list of ranges passed" do
      range = IOChannel::ChannelRange.from_string "0.0.0100,50,0.0.0100-0.0.0102"
      expect(range.matching_channels).to match_array(["0.0.0100","0.0.0050","0.0.0101","0.0.0102"])
      range = IOChannel::ChannelRange.from_string "0.0.0001,0.0.0100-102"
      expect(range.matching_channels).to match_array(["0.0.0001","0.0.0100","0.0.0101","0.0.0102"])
    end

    it "raises InvalidRangeValue exception if invalid range is passed" do
      expect{IOChannel::ChannelRange.from_string("invalid")}.to raise_error(IOChannel::InvalidRangeValue)
    end
  end
end
