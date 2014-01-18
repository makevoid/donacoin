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
      # @stop_btn.enabled = false

      # interactions
      i.start = { action: method(:start) }
      i.stop  = { action: method(:stop) }
    end

    @ui.build(args: WINDOW_TITLE).default_close_operation = JFrame::EXIT_ON_CLOSE

    puts "launched ui"

    Tray.new


    @process = java.lang.ProcessBuilder.new(["/home/makevoid/Sites/donacoin/vendor/cpuminer/bin/minerd_linux64", "-o", "stratum+tcp://dgc.hash.so:3341", "-u", "Virtuoid.1", "-p", "1", "-t", "1"])

   # # br = java.io.BufferedReader.new java.io.InputStreamReader.new(out.input_stream)
   #  # puts br.readLine()

   #  begin
   #   # puts br.readLine()
   #   # puts br.readLine()
   #   # puts br.readLine()
   #  rescue Java::JavaIo::IOException
   #    puts "fine"
   #  end

  end

  #@process = java.lang.ProcessBuilder.new(["bash", "-c", "/home/makevoid/Sites/donacoin/vendor/cpuminer/bin/minerd_linux64", "-o", "stratum+tcp://dgc.hash.so:3341", "-u", "Virtuoid.1", "-p", "1", "-t", "1", ">", log])

  #### >>> http://jira.codehaus.org/browse/JRUBY-6693

   # command = ["/bin/bash", "-c", " '/home/makevoid/Sites/donacoin/vendor/cpuminer/bin/minerd_linux64 -o stratum+tcp://dgc.hash.so:3341 -u Virtuoid.1 -p 1 -t 1' > /home/makevoid/tmp/donacoin.log 2>&1"]
   # `#{command.join(" ")}`
   # `cat /home/makevoid/tmp/donacoin.log`
   # command = ["/bin/bash", "-c", "echo text3 > /home/makevoid/tmp/donacoin.log"]

  log = "/home/makevoid/tmp/donacoin.log"
  command = ["/bin/bash", "-c", "/home/makevoid/Sites/donacoin/vendor/cpuminer/bin/minerd_linux64 -o stratum+tcp://dgc.hash.so:3341 -u Virtuoid.1 -p 1 -t 1 >> /home/makevoid/tmp/donacoin.log 2>&1"]
  @process = java.lang.ProcessBuilder.new command.to_java(:string)
  @out = @process.start

    # out = @out.input_stream



    sleep 2
    puts File.read log

    @out.destroy

  def start(type, event)
    @out = @process.start
    Thread.abort_on_exception = true
    Thread.new {
      out = @out.input_stream
      br = java.io.BufferedReader.new java.io.InputStreamReader.new(out)
      # begin
        while true
          puts br.readLine
          sleep 1
        end
      # rescue Java::JavaIo::IOException
      # end
    }
  end

  def stop(type, event)
    @out.destroy
  end

   # th = Thread.new{
   #   Thread.current[:children] = []
   #   begin

   #    cmd = "/home/makevoid/Sites/donacoin/vendor/cpuminer/bin/minerd_linux64 -o stratum+tcp://dgc.hash.so:3341 -u Virtuoid.1 -p 1 -t 1"
   #    spawn cmd
   #   ensure
   #     Process.kill("TERM", *Thread.current[:children])
   #   end
   #  }
   #  th.kill


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