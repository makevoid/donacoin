class Tray
  
  import java.awt.AWTException
  import java.awt.SystemTray
  import java.awt.PopupMenu
  import java.awt.MenuItem
  import java.awt.Toolkit
  import java.awt.event.ActionEvent  
  import java.awt.event.ActionListener
  
  def initialize
    image = Toolkit.getDefaultToolkit.getImage "#{PATH}/icon.png"
    
    tray = java.awt.SystemTray.getSystemTray  
    puts tray
  end
  
end