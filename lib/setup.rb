class Setup

  def initialize
  end

  def setup
    create_mining_binaries
    #...
  end

  def get_miner(path)
    self.java.lang.Object.new.java_class.resource_as_stream path
  end

  def create_mining_binaries
    path = "/vendor/cpuminer/bin/minerd_#{Utils.os}#{Utils.arch}"
    input = get_miner "/donacoin#{path}"
    input = get_miner path unless input

    output = java.io.FileOutputStream.new "miner_tmp"
    buf = Java::byte[1024].new
    bytes_read = 0
    while ( bytes_read = input.read(buf) ) > 0
      output.write(buf,0,bytes_read)
    end
    input.close()
    output.close()

    File.chmod 0755, "miner_tmp"
  end

end