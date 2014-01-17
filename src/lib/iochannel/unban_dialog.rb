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

require "iochannel/channels"
require "iochannel/channel_range"
require "yast"

module IOChannel
  class UnbanDialog
    include Yast::UIShortcuts
    include Yast::I18n

    def self.run
      Yast.import "UI"
      Yast.import "Label"
      dialog = UnbanDialog.new
      dialog.run
    end

    def run
      raise "Failed to create dialog" unless create_dialog

      begin
        return controller_loop
      ensure
        close_dialog
      end
    end

  private
    def create_dialog
      Yast::UI.OpenDialog dialog_content
    end

    def close_dialog
      Yast::UI.CloseDialog
    end

    def controller_loop
      while true do
        input = Yast::UI.UserInput
        case input
        when :ok
          begin
            channel_range_value = Yast::UI.QueryWidget(:channel_range, :Value)
            range = ChannelRange.from_string channel_range_value
          rescue InvalidRangeValue => e
            invalid_range_message(e.value)
          else
            puts range.inspect
            return range.matching_channels
          end
        when :cancel
          return nil
        else
          raise "Unknown action #{input}"
        end
      end
    end

    def invalid_range_message value
      msg = _("Specified range is invalid. Wrong value is inside snippet '#{value}'")
      widget = Label(msg)
      Yast::UI.ReplaceWidget(:message, widget)
    end

    def dialog_content
      VBox(
        heading,
        *unban_content,
        ending_buttons
      )
    end

    def ending_buttons
      HBox(
        PushButton(Id(:ok), Yast::Label.OKButton),
        PushButton(Id(:cancel), Yast::Label.CancelButton)
      )
    end

    def heading
      Heading(_("Unban Input/Output Channels"))
    end

    def unban_content
      [
        Label("List of ranges of channels to unban separated by comma.\n"+
          "Range can be channel, part of channel which will be filled to zero or range specified with dash.\n"+
          "Example value: 0.0.0001, AA00, 0.1.0100-200"),
        ReplacePoint(Id(:message), Empty()),
        InputField(Id(:channel_range), "Ranges to unban.", "")
      ]
    end
  end
end
