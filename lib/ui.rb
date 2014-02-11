# encoding: UTF-8

require 'profligacy/swing'
require 'profligacy/lel'

class Cause
  def self.all
    ["Wikipedia", "Wikileaks", "Riotvan"]
  end
end


class Donacoin::UI
  include_package 'javax.swing'
  include Profligacy

  require_relative 'textarea_formatter'

  require 'open3'

  WINDOW_TITLE = "Donacoin"

  Thread.abort_on_exception = true

  attr_accessor :dialog

  def initialize
    layout = "
     [ start | stop ]
     [ (0,50)*donation_label | _ ]
     [ cause_select | _ ]
     [ .minimize | >.settings ]
    "

    # mockup
    #
    # layout = "
    #  [ <start | stop ]
    #  [ donation_info ]
    #  [ settings ]
    # "
    # settings = "
    #   [ username ]
    #   [ speed_slider ]
    # "

    @ui = self.build_ui layout

    @frame = @ui.build(args: WINDOW_TITLE)
    @frame.location_relative_to = nil
    @frame.default_close_operation = JFrame::EXIT_ON_CLOSE

    puts "launched ui"

    Tray.new @frame

    # FIXME > Setups raises error in jar
    #
    Setup.new.setup

    load_preferences
  end

  def build_ui(layout)
    Swing::LEL.new(JFrame, layout) do |c, i| # c: component, i: interaction
      # components
      button = JButton.new "Start"
      font = java.awt.Font.new "Dialog", java.awt.Font::BOLD, 20
      button.font = font
      c.start = @start_btn = button
      c.stop  = @stop_btn = JButton.new "Stop"
      @stop_btn.enabled = false
      c.donation_label = @donation_label = JLabel.new "Press Start to begin donating"

      c.cause_select = @cause_select = JComboBox.new
      Cause.all.each do |cause|
        @cause_select.add_item cause
      end
      c.minimize = JButton.new "Minimize in Tray"
      c.settings = JButton.new "Settings"

      # interactions
      i.start        = { action: method(:start)        }
      i.stop         = { action: method(:stop)         }
      i.cause_select = { action: method(:cause_select) }
      i.minimize     = { action: method(:minimize)     }
      i.settings     = { action: method(:settings)     }
    end
  end

  def start(type, event)
    Settings.instance.cause = @cause_select.selected_item
    @miner = Miner.new
    @miner.start

    @start_btn.enabled = false
    @stop_btn.enabled  = true

    @speed_thread = Thread.new {
      while true
        @donation_label.text = unless @miner.speed == 0
          "<html><center>You are donating<br>#{@miner.speed} €/cents per day</center></html>"
        else
          "Starting donation process..."
        end
        sleep 0.5
      end
    }

    @notify_thread = Thread.new {
      while true
        prov = Provisioner.new Settings.host
        prov.notify_mining speed: @miner.speed, username: Settings.instance.username, cause: Settings.instance.cause, uid: Settings.instance.uid

        sleep 5
      end
    }
  end

  def stop(type, event)
    @miner.stop

    @start_btn.enabled = true
    @stop_btn.enabled  = false
    @donation_label.text = "Press Start to resume donating"
    @speed_thread.terminate
    @notify_thread.terminate
  end

  def cause_select(type, event)
    Settings.instance.cause = @cause_select.selected_item
  end

  def minimize(type, event)
    @frame.state = java.awt.Frame::ICONIFIED
  end

  def settings(type, event)
    #@dialog ||=
    unless defined? @dialog
      @dialog = SettingsDialog.new @frame, true
    else
      #@dialog.ui.build args: "Settings"
      @dialog.frame.visible = true
    end
  end

  private

  def load_preferences
    Settings.instance.prefs_load
  end

  def connection_test
    http = Net::HTTP.new "158.167.211.53", 6081
    http.open_timeout = 5 # in seconds
    http.read_timeout = 5 # in seconds
    http.request Net::HTTP::Get.new("/")
  end
end


# external:

def persist_window
  event_thread = nil
  SwingUtilities.invokeAndWait { event_thread = java.lang.Thread.currentThread }
  event_thread.join
end