require 'profligacy/swing'
require 'profligacy/lel'



class Donacoin::UI
  include_package 'javax.swing'
  include Profligacy

  require_relative 'textarea_formatter'
  require_relative 'ui_actions'
  include UIActions

  WINDOW_TITLE = "Donacoin"


  Thread.abort_on_exception = true

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


#2>&1

# 2> /home/makevoid/tmp/donacoin.log

# apache commons

# java_import java.io.ByteArrayOutputStream

# require 'commons-exec.jar'
# java_import org.apache.commons.exec.CommandLine
# java_import org.apache.commons.exec.DefaultExecutor
# java_import org.apache.commons.exec.Executor
# java_import org.apache.commons.exec.PumpStreamHandler



# output_stream = ByteArrayOutputStream.new
# cl = CommandLine.parse "ping google.com"
# executor = DefaultExecutor.new
# stream_handler = PumpStreamHandler.new output_stream
# executor.set_stream_handler stream_handler
# executor.execute cl
# puts output_stream.to_string



###


    # java_import java.util.Scanner
    # # runtime = Runtime.getRuntime
    # # process = runtime.exec "/home/makevoid/Sites/donacoin/bin/miner"
    # cmd = "/home/makevoid/Sites/donacoin/bin/miner"
    # @process = java.lang.ProcessBuilder.new cmd




    # scanner = Scanner.new @process.getInputStream


    # Thread.new {
    #   scanner = Scanner.new @process.getInputStream
    #   puts "scanning"
    #   while scanner.hasNextLine
    #     puts "line"
    #     line = scanner.nextLine
    #     puts line
    #   end
    # }

    cmd = "/home/makevoid/Sites/donacoin/bin/miner"
    t = Thread.new {
      proc = IO.popen(cmd) do |f|
        # puts f.read
        until f.eof?
          puts "miner > #{f.gets}"
        end
      end
    }
    t.kill

    ##############

    # slave



    require 'slave'
    class Server
      def start
        cmd = "/home/makevoid/Sites/donacoin/bin/miner"
        `#{cmd}`
      end
    end

    slave = Slave.new object: Server.new

    server = slave.object
    server.start

    slave.shutdown


    ##############
    cmd = "/home/makevoid/Sites/donacoin/bin/miner"
    pid = spawn cmd
    Process.detach pid
    Process.exit! pid

    ##############

    require 'open3'
    cmd = "/home/makevoid/Sites/donacoin/bin/miner"
    stdin, stdout, stderr, wait_thr = Open3.popen3 cmd

    Thread.new {
      while true
        begin
          puts stderr.read_nonblock 10
        rescue Errno::EAGAIN
          puts "nothing to read"
        end
        sleep 1
      end
    }

    puts wait_thr[:pid]

    `pkill -TERM -P #{wait_thr[:pid]}`

    #  taskkill /f /im procname.exe

    #############

    @out = @process.start

  end


  def start(type, event)
    @out = @process.start

  end

  def stop(type, event)
    @out.destroy
  end

  #@process = java.lang.ProcessBuilder.new(["bash", "-c", "/home/makevoid/Sites/donacoin/vendor/cpuminer/bin/minerd_linux64", "-o", "stratum+tcp://dgc.hash.so:3341", "-u", "Virtuoid.1", "-p", "1", "-t", "1", ">", log])

  #### >>> http://jira.codehaus.org/browse/JRUBY-6693

   # command = ["/bin/bash", "-c", " '/home/makevoid/Sites/donacoin/vendor/cpuminer/bin/minerd_linux64 -o stratum+tcp://dgc.hash.so:3341 -u Virtuoid.1 -p 1 -t 1' > /home/makevoid/tmp/donacoin.log 2>&1"]
   # `#{command.join(" ")}`
   # `cat /home/makevoid/tmp/donacoin.log`
   # command = ["/bin/bash", "-c", "echo text3 > /home/makevoid/tmp/donacoin.lo


   ####

  # log = "/home/makevoid/tmp/donacoin.log"
  # command = ["/bin/bash", "-c", "/home/makevoid/Sites/donacoin/vendor/cpuminer/bin/minerd_linux64 -o stratum+tcp://dgc.hash.so:3341 -u Virtuoid.1 -p 1 -t 1 >> /home/makevoid/tmp/donacoin.log 2>&1"]
  # @process = java.lang.ProcessBuilder.new command.to_java(:string)
  # @process.redirect_input(Redirect::INHERIT)



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