class OS
  def self.linux?
    Utils.os == :linux
  end

  def self.osx?
    Utils.os == :osx
  end

  def self.windows?
    Utils.os == :windows
  end
end

class Utils

  require 'rbconfig'

  def self.os
    @@os ||= (
      host_os = RbConfig::CONFIG['host_os']
      case host_os
        when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
          :windows
        when /darwin|mac os/
          :osx
        when /linux/
          :linux
        else
          raise Error::WebDriverError, "unknown os: #{host_os.inspect}"
      end
    )
  end

  def self.arch
    @@arch ||= if RbConfig::CONFIG['host_cpu'] == "x86_64"
      64
    else
      32
    end
  end

  def self.exe(cmd)
    puts cmd
    out =`#{cmd}`
    puts out
    out
  end

  def self.cores_usable
    (cores.to_f / 2).ceil # half the cores
    # cores - 1
  end

  def self.max_threads
    java.lang.Runtime.getRuntime.availableProcessors
  end

  def self.cores
    @@cores ||= (
      cores = 2 # default core numbers
      string = case os
      when :windows
        exe'WMIC CPU Get NumberOfLogicalProcessors /Format:List' #=> NumberOfLogicalProcessors=2
      when :osx
        exe 'sysctl hw.physicalcpu' #=> hw.physicalcpu: 4
      when :linux
        exe 'lscpu | grep "Core(s) per socket"' #=> Core(s) per socket:    4
      end
      match = string.match(/\d$/)
      cores = match[0] if match
      cores
    )
  end

  def self.tmp_path
    java.lang.System.getProperty "java.io.tmpdir"        
  end
end