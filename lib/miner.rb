JObject = java.lang.Object

class Miner

  @@pool = "-o stratum+tcp://dgc.hash.so:3341 -u Virtuoid.1 -p 1"
  
  require 'fileutils'

  def start
    Thread.abort_on_exception
      

    cmd = if Utils.os == :osx
      "#{PATH}/vendor/cpuminer/bin/minerd_osx64 #{@@pool}"
    elsif Utils.os == :windows
      path = File.expand_path "../../../../", __FILE__
      path = path[5..-1]
      puts path
      "#{path}/windows_32/minerd.exe #{@@pool}"
    elsif Utils.os == :linux
      "#{path}/vendor/cpuminer/bin/minerd_linux"
    end        
    
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
    if Utils.os == :osx
      puts `killall minerd_osx64`
    elsif Utils.os == :windows
      puts `taskkill /IM minerd.exe /F`
    elsif Utils.os == :linux
      puts `killall minerd_linux`
    end    
    
  end

end

