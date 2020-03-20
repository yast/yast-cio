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

require "yui"

module IOChannel
  class UnbanDialog
    include Yast::I18n
    include Yast::Logger

    def self.run
      Yast.import "Label"

      dialog = UnbanDialog.new
      dialog.run
    end

    def run
      textdomain "cio"

      log.info "creating dialog"
      dialog = create_dialog
      log.info "dialog created #{dialog.inspect}"
      raise "Failed to create dialog" unless dialog

      begin
        return controller_loop(dialog)
      ensure
        dialog.destroy
      end
    end

  private

    def ui_factory
      Yui::YUI::widget_factory
    end

    def create_dialog
      @dialog = ui_factory.create_dialog(Yui::YPopupDialog)
      dialog_content(@dialog)
      @dialog
    end

    def controller_loop(dialog)
      while true do
        input = dialog.wait_for_event
        log.info input.inspect
        return nil if input.event_type == Yui::YEvent::CancelEvent

        case input.widget
        when @ok_button
          begin
            channel_range_value = @input_field.value
            range = ChannelRange.from_string channel_range_value
          rescue InvalidRangeValue => e
            invalid_range_message(e.value)
          else
            return range.matching_channels
          end
        when @cancel_button
          return nil
        else
          raise "Unknown action #{input}"
        end
      end
    end

    def invalid_range_message value
      # TRANSLATORS: %s stands for the smallest snippet inside which we detect syntax error
      msg = _("Specified range is invalid. Wrong value is inside snippet '%s'") % value
      # This is what ycp-ui-bindings does - remove old child, add new one, show it, recalculate dialog and re-resolve shortcuts
      @replace_point.delete_children
      widget = ui_factory.create_label(@replace_point, msg)
      @replace_point.show_child
      @dialog.set_initial_size
      @dialog.check_shortcuts
    end

    def dialog_content(parent)
      vbox = ui_factory.create_vbox(parent)

      heading(vbox)
      unban_content(vbox)
      ending_buttons(vbox)
    end

    def ending_buttons(parent)
      hbox = ui_factory.create_hbox(parent)

      @ok_button = ui_factory.create_push_button(hbox, Yast::Label.OKButton)
      @cancel_button = ui_factory.create_push_button(hbox, Yast::Label.CancelButton)
    end

    def heading(parent)
      ui_factory.create_heading(parent, _("Unban Input/Output Channels"))
    end

    def unban_content(parent)
      ui_factory.create_label(parent, _("List of ranges of channels to unban separated by comma.\n"+
          "Range can be channel, part of channel which will be filled to zero or range specified with dash.\n"+
          "Example value: 0.0.0001, AA00, 0.1.0100-200"))
      @replace_point = ui_factory.create_replace_point(parent)
      ui_factory.create_empty(@replace_point)
      @input_field = ui_factory.create_input_field(parent, _("Ranges to Unban."))
    end
  end
end
