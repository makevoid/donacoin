module UIActions

  @@thread = nil
  @@cmd = "/home/makevoid/Sites/donacoin/vendor/cpuminer/bin/minerd_linux64 -o stratum+tcp://dgc.hash.so:3341 -u Virtuoid.1 -p 1 -t 1"

  # def start(type, event)
  #   puts "starting..."
  #   @start_btn.enabled = false
  #   @stop_btn.enabled = true
  #   # Miner2.instance.start
  #   # sleep 1
  #   # Miner2.instance.stop

  #   @status = :start
  # end

  # def stop(type, event)
  #   @start_btn.enabled = true
  #   @stop_btn.enabled = false
  #   # @miner.stop

  #   @status = :running
  # end

end
