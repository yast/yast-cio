require "iochannel/channels"
require "yast"

module IOChannel
  class ChannelsDialog
    include Yast::UIShortcuts
    include Yast::I18n

    def self.run
      Yast.import "UI"
      dialog = ChannelsDialog.new
      dialog.run
    end

    def initialize
      @channels = Channels.allowed
    end

    def run
      return unless create_dialog

      begin
        return controller_loop
      ensure
        close_dialog
      end
    end

  private
    DEFAULT_SIZE_OPT = Yast::Term.new(:opt, :defaultsize)

    def create_dialog
      Yast::UI.OpenDialog DEFAULT_SIZE_OPT, dialog_content
    end

    def close_dialog
      Yast::UI.CloseDialog
    end

    def controller_loop
      input = Yast::UI.UserInput
      case input
      when :ok, :cancel
        return input
      when :filter_text
        Yast::UI.ChangeWidget(Id(:channels_table), :Items, channels_items)
      else
        raise "Unknown action #{input}"
      end
    end

    def dialog_content
      VBox(
        headings,
        HBox(
          channels_table,
          action_buttons
        ),
        ending_buttons
      )
    end

    def headings
      Heading(_("Available Input/Output Channels"))
    end

    def channels_table
      Table(
        Id(:channels_table),
        Header(_("Device"), _("Used")),
        channels_items
      )
    end

    def channels_items
      prefiltered_channels.map do |channel|
        Item(
          Id(channel.device),
          channel.device,
          channel.used? ? _("yes") : _("no")
        )
      end
    end

    def prefiltered_channels
      filter = Yast::UI.QueryWidget(Id(:filter_text), :Value)

      return @channels if !filter || filter.empty?

      @channels.select do |channel|
        channel.include? filter
      end
    end

    def action_buttons
      VBox(
        TextEntry(Id(:filter_text), Opt(:notify),""),
#        PushButton(Id(:confirm_filter), _("&Confirm Filter"))
      )
    end

    def ending_buttons
      PushButton(Id(:ok), _("&OK"))
    end
  end
end
