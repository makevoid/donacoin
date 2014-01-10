module EptiMecha
end

require_relative "core"
require_relative "ui"

# persist window in jar
event_thread = nil
SwingUtilities.invokeAndWait { EptiMecha::UI.new } # normal launch
SwingUtilities.invokeAndWait { event_thread = java.lang.Thread.currentThread }
event_thread.join