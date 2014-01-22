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
    include_package 'javax.swing'
    include Profligacy

    MAX_THREADS = Utils.max_threads

    def initialize(frame, modal)
      super frame, modal
      layout = "
       [ user_label               ]
       [ (150,30)*user_field      ]
       [ threads_label            ]
       [ (150,30)*threads_slider  ]
       [ save                     ]     
      "

      @threads = Utils.cores_usable

      @ui = Swing::LEL.new(JFrame, layout) do |c, i|
        c.user_label = JLabel.new "Username:"
        c.user_field = @user_field = JTextField.new
        c.threads_label = @threads_label = JLabel.new "Threads (#{@threads}):"
        c.threads_slider = @threads_slider = JSlider.new 1, MAX_THREADS
        c.save = @save_button = JButton.new "Save"

        i.user_field      = { action: method(:update_user)    }
        i.threads_slider  = { change: method(:threads_slider) }
        i.save            = { action: method(:save)           }
      end

      @ui.build args: "Settings"
    end

    def save(type, event)      
      puts @ui.container.dispose
    end

    def threads_slider(type, event)
      @threads = @threads_slider.value
      @threads_label.text = "Threads (#{@threads}):"
    end

    def update_user(type, event)
      @username = @user_field.text
      puts @username
    end
  end


  def initialize
    layout = "
     [ <start | stop ]
     [ (150,40)*donation_label ]
     [ <settings ]
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