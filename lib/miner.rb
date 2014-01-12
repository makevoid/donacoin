JObject = java.lang.Object

class Miner

  @@pool = "-o stratum+tcp://dgc.hash.so:3341 -u Virtuoid.1 -p 1"
  
  require 'fileutils'

  def start
    Thread.abort_on_exception
      


    # osx
    #
    #puts `#{PATH}/vendor/cpuminer/bin/minerd_osx64 #{@@pool}`

    # windows
    #
    path = File.expand_path "../../../../", __FILE__
    path = path[5..-1]
    puts path
    cmd = "#{path}/windows_32/minerd.exe #{@@pool}"
    
    Thread.new {
      IO.popen(cmd) do |f|
        until f.eof?
          puts "antani > #{f.gets}"
        end
      end
    }
  end

  def stop
    puts "stopping"    
    #puts `killall minerd_osx64`
    puts `taskkill /IM minerd.exe /F`
  end

end

