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
      read_channels
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

    def read_channels
      @channels = Channels.allowed
    end

    def redraw_channels
      Yast::UI.ChangeWidget(:channels_table, :Items, channels_items)
    end

    def controller_loop
      while true do
        input = Yast::UI.UserInput
        case input
        when :ok, :cancel
          return :ok
        when :filter_text
          redraw_channels
        when :clear
          Yast::UI.ChangeWidget(:channels_table, :SelectedItems, [])
        when :select_all
          Yast::UI.ChangeWidget(:channels_table, :SelectedItems, prefiltered_channels.map(&:device))
        when :block
          block_channels
          read_channels
          redraw_channels
        else
          raise "Unknown action #{input}"
        end
      end
    end

    def block_channels
      devices = Yast::UI.QueryWidget(:channels_table, :SelectedItems)
      channels = Channels.new(devices.map {|d| Channel.new(d) })
      channels.block
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
        Opt(:multiSelection),
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
      filter = Yast::UI.QueryWidget(:filter_text, :Value)

      return @channels if !filter || filter.empty?

      @channels.select do |channel|
        channel.device.include? filter
      end
    end

    def action_buttons
      VBox(
        Label(_("Filter channels")),
        InputField(Id(:filter_text), Opt(:notify),""),
        PushButton(Id(:select_all), _("&Select All")),
        PushButton(Id(:clear), _("&Clear selection")),
        PushButton(Id(:block), _("&Blacklist Selected Channels")),
      )
    end

    def ending_buttons
      PushButton(Id(:ok), _("&Exit"))
    end
  end
end
