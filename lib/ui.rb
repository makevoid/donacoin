# encoding: UTF-8

require 'profligacy/swing'
require 'profligacy/lel'



class Donacoin::UI
  include_package 'javax.swing'
  include Profligacy

  require_relative 'textarea_formatter'


  require 'open3'

  WINDOW_TITLE = "Donacoin"


  Thread.abort_on_exception = true

  class SettingsDialog < JDialog
    include Profligacy

    def initialize(frame, modal)
      super frame, modal
      layout = "
       [ username ]
      "
      @ui = Swing::LEL.new(JFrame, layout) do |c, i|
        c.username = JLabel.new "username"
      end


      @ui.build(args: "yo")
    end
  end


  def initialize
    layout = "
     [ <start | stop ]
     [ (150,40)*donation_label ]
     [ settings ]
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

    @ui = Swing::LEL.new(JFrame, layout) do |c, i| # c: component, i: interaction
      # components

      c.start = @start_btn = JButton.new "Start"
      c.stop  = @stop_btn = JButton.new "Stop"
      @stop_btn.enabled = false
      c.settings = JButton.new "Settings"

      c.donation_label = @donation_label = JLabel.new "Press Start to begin donating"

      # interactions
      i.start     = { action: method(:start)    }
      i.stop      = { action: method(:stop)     }
      i.settings  = { action: method(:settings) }
    end

    @frame = @ui.build(args: WINDOW_TITLE)
    @frame.default_close_operation = JFrame::EXIT_ON_CLOSE

    puts "launched ui"

    Tray.new
  end

  def settings(type, event)
    dialog = SettingsDialog.new @frame, true
    # dialog = JDialog.new @frame, true
    # JOptionPane.showMessageDialog @frame, "Could not open file",
    #             "Error", JOptionPane::ERROR_MESSAGE
  end

  def start(type, event)
    @miner = Miner.new
    @miner.start

    @start_btn.enabled = false
    @stop_btn.enabled  = true

    @speed_thread = Thread.new {
      while true
        @donation_label.text = unless @miner.speed == 0
          "<html>You are donating<br>#{@miner.speed} €/cents per day</html>"
        else
          "Starting donation process..."
        end
        sleep 0.5
      end
    }
  end

  def stop(type, event)
    @miner.stop

    @start_btn.enabled = true
    @stop_btn.enabled  = false
    @donation_label.text = "Press Start to resume donating"
    @speed_thread.terminate
  end

  private

  def connection_test
    http = Net::HTTP.new "158.167.211.53", 6081
    http.open_timeout = 5 # in seconds
    http.read_timeout = 5 # in seconds
    http.request Net::HTTP::Get.new("/")
  end
end

def persist_window
  event_thread = nil
  SwingUtilities.invokeAndWait { event_thread = java.lang.Thread.currentThread }
  event_thread.join
end