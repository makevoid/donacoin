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
    popup.add start
    start2 = MenuItem.new "Start2"
    popup.add start2
    quit = MenuItem.new "Quit"
    popup.add quit

    tray_icon.popup_menu = popup

    start.add_action_listener StartAction.new
    start2.add_action_listener do |evt|
      puts "Start 2!!!!"
    end
    quit.add_action_listener do |evt|
      java.lang.System.exit 0
    end

    tray = java.awt.SystemTray.getSystemTray
    tray.add tray_icon
  end

end