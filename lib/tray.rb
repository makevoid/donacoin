class Tray
  
  import java.awt.AWTException
  import java.awt.SystemTray
  import java.awt.PopupMenu
  import java.awt.MenuItem
  import java.awt.Toolkit
  import java.awt.event.ActionEvent  
  import java.awt.event.ActionListener
  
  def initialize
    tray = SystemTray.getSystemTray  
    puts tray
  end
  
end