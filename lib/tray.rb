class StartAction
  include java.awt.event.ActionListener

  def actionPerformed(event)
    puts "DAIANE!!!!"
  end
end

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
    linux = ""
    linux =
    image = Toolkit.getDefaultToolkit.getImage "#{PATH}/icon.png"
    # TODO: icon transparency:  check: http://stackoverflow.com/questions/331407/java-trayicon-using-image-with-transparent-background
    tray_icon = TrayIcon.new image, "DonaCoin"
    tray_icon.image_auto_size = true

    popup = PopupMenu.new
    start = MenuItem.new "Start"
    start.addActionListener StartAction.new
    popup.add start
    start2 = MenuItem.new "Start2"
    popup.add start2
    start3 = MenuItem.new "Start3"
    popup.add start3

    tray_icon.popup_menu = popup



    tray = java.awt.SystemTray.getSystemTray
    tray.add tray_icon
  end

end