module UIActions  
  
  def start(type, event)
    puts "starting..."
    @start_btn.disable
    @stop_btn.enable
    @miner.start
  end

  def stop(type, event)
    @start_btn.enable
    @stop_btn.disable
    @miner.stop
  end

end
