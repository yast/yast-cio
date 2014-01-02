#! rspec

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
