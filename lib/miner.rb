class Miner

  @@pool = "-o stratum+tcp://dgc.hash.so:3341 -u Virtuoid.1 -p 1"
  

  def start
    puts "starting"
    Thread.abort_on_exception
    #puts `C: ; dir`
    # Runtime.getRuntime().exec("netsh")
    Runtime.getRuntime().exec("test.exe", null, new File('Z:\Documents\windows'))
    Thread.new {
      #puts `#{PATH}/vendor/cpuminer/bin/minerd_osx64 #{@@pool}`

      # puts `#{PATH}/vendor/cpuminer/bin/windows_32/minerd.exe #{@@pool}`
    }
  end

  def stop
    puts "stopping"    
    #puts `killall minerd_osx64`
    puts `taskkill /IM minerd.exe`
  end

end

