module UIActions  
  
  $t = nil

  def start(type, event)
    puts "starting..."
    @miner.start
  end

  def stop(type, event)
    @miner.stop
  end

end
