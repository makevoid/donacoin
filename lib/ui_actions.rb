module UIActions

  def start(type, event)
    puts "starting..."
    @start_btn.enabled = false
    @stop_btn.enabled = true
    @miner.start
    sleep 1
    @miner.stop
  end

  def stop(type, event)
    @start_btn.enabled = true
    @stop_btn.enabled = false
    @miner.stop
  end

end
