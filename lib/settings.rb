class Settings

  attr_accessor :username
  attr_accessor :cause
  attr_writer   :threads

  attr_reader   :uid

  # application settings
  @@host = "donacoin.com"   # production
  #@@host = "mkvd-32284.euw1.nitrousbox.com" # dev nitrous
  @@host = "localhost:3000" # dev

  def self.host
    @@host
  end

  # user settings

  require 'digest/md5'
  def self.uid
    Digest::MD5.hexdigest(rand 9999999)[0..10]
  end

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