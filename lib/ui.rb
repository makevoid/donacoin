require 'profligacy/swing'
require 'profligacy/lel'


class Donacoin::UI
  include_package 'javax.swing'
  include Profligacy

  require_relative 'textarea_formatter'
  require_relative 'ui_actions'
  include UIActions



  WINDOW_TITLE = "Donacoin"

  def initialize
    layout = "
     [ <start | stop ]     
    "
    @ui = Swing::LEL.new(JFrame, layout) do |c, i| # c: component, i: interaction
      # components
      c.start = JButton.new "Start"
      c.stop  = JButton.new "Stop"


      # interactions      
      i.start = { action: method(:start) }
      i.stop  = { action: method(:stop) }
    end

    @ui.build(args: WINDOW_TITLE).default_close_operation = JFrame::EXIT_ON_CLOSE

    puts "launched ui"
    Thread.new {
      @miner = Miner.new
    }
    @miner.start
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