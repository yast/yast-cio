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

require "iochannel/channel"

describe IOChannel::Channel do
  def channel overwritten_params={}
    values = {
      :used   => false,
      :device => "0.0.0600"
    }
    values.merge!(overwritten_params)

    IOChannel::Channel.new values[:device], values[:used]
  end

  describe "#initialize" do
    it "raises exception if device is nil" do
      expect{channel(:device => nil)}.to raise_error
    end
  end

  describe "#used?" do
    it "returns true if channel is used" do
      expect(channel(:used => true).used?).to be_true
    end

    it "returns false if channel is not used" do
      expect(channel(:used => false).used?).to be_false
    end

  end
end
