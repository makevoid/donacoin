class Setup

  def initialize
  end

  def setup
    create_mining_binaries
    #...
  end

  def get_resource_path(path)
    self.java.lang.Object.new.java_class.resource_as_stream path
  end

  def extract_from_jar(input, dest)
    output = java.io.FileOutputStream.new dest    
    buf = Java::byte[1024].new
    bytes_read = 0    
    while ( bytes_read = input.read(buf) ) > 0
      output.write buf, 0, bytes_read
    end    
    input.close
    output.close
  end

  def unzip(path)            
    classes = %w(FileInputStream FileOutputStream)
    classes.map{ |klass| java_import "java.io.#{klass}" }

    classes = %w(ZipInputStream ZipEntry)
    classes.map{ |klass| java_import "java.util.zip.#{klass}" }    
    zis = ZipInputStream.new FileInputStream.new path
    
    ze = zis.next_entry

    while (!ze.nil?) do
      entry_name = ze.name
      
      f = java.io.File.new "#{Utils.tmp_path}/#{entry_name}"
      f.parent_file.mkdirs
      fos = FileOutputStream.new f
      len = 0
      buffer = Java::byte[1024].new      
      while ( len = zis.read(buffer) ) > 0 do
        fos.write buffer, 0, len
      end
      fos.close
      ze = zis.next_entry
    end
    zis.close_entry
    zis.close
    
  end

  def unzip_windows
    miner_tmp = "#{Utils.tmp_path}/miner_tmp.zip"
    path = "/donacoin/vendor/cpuminer/windows_#{Utils.arch}.zip"
    input = get_resource_path path    
    extract_from_jar input, miner_tmp     
    unzip miner_tmp
  end  

  def create_miner 
    miner_tmp = "#{Utils.tmp_path}/miner_tmp" 
    path = "/vendor/cpuminer/bin/minerd_#{Utils.os}#{Utils.arch}"        
    input = get_resource_path "/donacoin#{path}"
    input = get_resource_path path unless input    
    
    extract_from_jar input, miner_tmp

    File.chmod 0755, miner_tmp
  end

  def create_mining_binaries
       
    if Utils.os == :windows        
      unzip_windows           
    else 
      create_miner 
    end
  end

end