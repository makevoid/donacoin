module Donacoin
end

require_relative "setup"
require_relative "utils"
require_relative "provisioner"
require_relative "settings"
require_relative "miner"
require_relative "tray"
require_relative "ui"
require_relative "ui/settings"


# persist window in jar
event_thread = nil
SwingUtilities.invokeAndWait { DONACOIN = Donacoin::UI.new } # normal launch
SwingUtilities.invokeAndWait { event_thread = java.lang.Thread.currentThread }
event_thread.join