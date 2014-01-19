JObject = java.lang.Object

class Miner

  @@pool = "-o stratum+tcp://dgc.hash.so:3341 -u Virtuoid.1 -p 1"

  require 'fileutils'

  @@settings = {
    pool: "stratum+tcp://dgc.hash.so:3341",
    worker_user: "donacoin.2",
    worker_pass: "2",
    mining_value: 0.00431, # eur / 1 kH/s per day - https://www.litecoinpool.org/calc?hashrate=100&power=&energycost=0.10&currency=USD
  }


  @@cmd = "/home/makevoid/Sites/donacoin/vendor/cpuminer/bin/minerd_linux64 -o stratum+tcp://dgc.hash.so:3341 -u Virtuoid.1 -p 1 -t 1"

  attr_reader :speed

  def initialize
    # log machine infos
    puts "running on: #{Utils.os}, arch: #{Utils.arch}"
    @speed = 0
  end

  def start_cmd
    # cmd = "/home/makevoid/Sites/donacoin/bin/miner"

    unless Utils.os == :windows
      bin = if Utils.os == :linux
        "cpuminer/bin/minerd_linux#{Utils.arch}"
      elsif Utils.os == :osx
        "cpuminer/bin/minerd_osx#{Utils.arch}"
      end

      cmd = "#{PATH}/vendor/#{bin}"
    else
      path = File.expand_path "../../../../", __FILE__
      path = path[5..-1]
      puts path
      cmd = "#{path}/windows_32/minerd.exe"
    end

    cmd = "#{cmd} #{@@pool}"
    "#{cmd} -t #{Utils.cores_usable}"
  end

  def start
    stdin, stdout, stderr, @wait_thr = Open3.popen3 start_cmd

    @t = Thread.new {
      first_match = false
      while true
        unless stderr.eof?
          line = stderr.readline
          puts line
          # cpuminer specific - matches thread lines: /s, (\d+\.\d+)/ [remember to multiply for Utils.cores_usable]
          regex = unless first_match
            /s, (\d+\.\d+)/
          else
            /\), (\d+\.\d+)/
          end
          match = line.match(regex)
          if match
            multiplier = 1
            unless first_match
              first_match = true
              multiplier = Utils.cores_usable
            end
            match = match[1]
            @speed = (match.to_f * @@settings[:mining_value] * 100 * multiplier).round 1
          end
        end
        sleep 0.2
      end
    }
  end

  def stop
    unless Utils.os == :windows
      puts @wait_thr[:pid]
      puts `pkill -TERM -P #{@wait_thr[:pid]}`
      puts `kill -9 #{@wait_thr[:pid]}`
    else
      `taskkill /IM minerd.exe /F`
    end
    @t.terminate
  end

  ##

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

  #  if Utils.os == :osx
  #    puts `killall minerd_osx64`
  #  elsif Utils.os == :windows
  #    puts `taskkill /IM minerd.exe /F`
  #  elsif Utils.os == :linux
  #    puts `killall minerd_linux`
  #  end

  def restart
    stop
    sleep 2
    start
  end

end