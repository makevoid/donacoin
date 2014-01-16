require 'profligacy/swing'
require 'profligacy/lel'

class Miner2 
  
  @@cmd = "/Users/makevoid/Sites/donacoin/vendor/cpuminer/bin/minerd_osx64 -o stratum+tcp://dgc.hash.so:3341 -u Virtuoid.1 -p 1 -t 1"
  
  def self.instance
    @@miner ||= new
  end
  
  def start
    # @@proc = IO.popen(@@cmd) do |f|
    #   until f.eof?
    #     puts "miner > #{f.gets}"
    #   end
    # end
    
    
    @@pid = spawn @@cmd 
    
    # t = Thread.new {
    #   @@proc = IO.popen(@@cmd) do |f|
    #     # puts f.read
    #     until f.eof?
    #       puts "miner > #{f.gets}"
    #     end
    #   end
    # }
  end
  
  def kill
    Process.kill 'KILL', @@pid
  end
  
end

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

      # interactions      
      i.start = { action: method(:start) }
      i.stop  = { action: method(:stop) }
    end

    @ui.build(args: WINDOW_TITLE).default_close_operation = JFrame::EXIT_ON_CLOSE

    puts "launched ui"
  
    Tray.new

    @miner = nil
    Thread.abort_on_exception
    @miner = Miner.new
    Thread.new {
      @miner.get_settings
    }
    # @miner.start# - test only on osx
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