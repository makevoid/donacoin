class Settings

  attr_accessor :username
  attr_writer   :threads

  def self.instance
    @@settings ||= new
  end

  def threads
    @threads ||= Utils.cores_usable
  end

  def self.prefs_java
    prefs_root = java.util.prefs.Preferences.user_root
    prefs_root.node "com.donacoin.settings"
  end

  def prefs_load
    prefs = Settings.prefs_java
    self.username = prefs.get     "username", nil
    self.threads  = prefs.get_int "threads",  threads

    puts "loaded prefs: #{self.inspect}"
  end

  def prefs_save
    prefs = Settings.prefs_java
    puts "saving prefs: #{self.inspect}"

    prefs.put     "username", @username
    prefs.put_int "threads",  @threads
  end

end