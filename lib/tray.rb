class Tray
  
  import java.awt.AWTException
  import java.awt.TrayIcon
  import java.awt.SystemTray
  import java.awt.PopupMenu
  import java.awt.MenuItem
  import java.awt.Toolkit
  import java.awt.event.ActionEvent  
  import java.awt.event.ActionListener
  
  PATH = File.expand_path "../../", __FILE__
  
  def initialize
    image = Toolkit.getDefaultToolkit.getImage "#{PATH}/icon.png"
    tray_icon = TrayIcon.new image, "DonaCoin"
    
    tray = java.awt.SystemTray.getSystemTray 
    tray.add tray_icon 
  end
  
end