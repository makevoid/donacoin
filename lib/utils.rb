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
  
  def self.exec(cmd)
    puts cmd
    `#{cmd}`
    cmd
  end
  
  def self.cores_usable
    (cores.to_f / 2).ceil # half the cores
    # cores - 1
  end

  def self.cores
    @@cores ||= (
      cores = 2 # default core numbers
      string = case os
      when :windows
        exec 'WMIC CPU Get NumberOfLogicalProcessors /Format:List' #=> NumberOfLogicalProcessors=2
      when :osx
        exec 'sysctl hw.physicalcpu' #=> hw.physicalcpu: 4
      when :linux
        exec 'lscpu | grep "Core(s) per socket"' #=> Core(s) per socket:    4
      end
      match = string.match(/\d$/)
      cores = match[0] if match 
      cores
    )
  end
end