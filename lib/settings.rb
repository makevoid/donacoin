class Settings

  def self.instance
    @@settings ||= new
  end

  def threads
    @@threads ||= Utils.cores_usable
  end

  def threads=(threads)
    @@threads = threads
  end

end