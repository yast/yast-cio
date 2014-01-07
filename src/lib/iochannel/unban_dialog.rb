require "iochannel/channels"
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
        when :ok, :cancel
          return input
        else
          raise "Unknown action #{input}"
        end
      end
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
        ReplacePoint(Id(:message), Empty()),
        InputField(Id(:channel_range), "")
      ]
    end
  end
end
