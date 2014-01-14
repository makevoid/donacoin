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
        when /solaris|bsd/
          :unix
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

end