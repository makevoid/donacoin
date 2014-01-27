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

  def initialize(frame)
    linux = ""
    linux =
    image = Toolkit.getDefaultToolkit.getImage "#{PATH}/icon.png"
    # TODO: icon transparency:  check: http://stackoverflow.com/questions/331407/java-trayicon-using-image-with-transparent-background
    tray_icon = TrayIcon.new image, "DonaCoin"
    tray_icon.image_auto_size = true

    popup = PopupMenu.new
    show = MenuItem.new "Show"
    popup.add show
    quit = MenuItem.new "Quit"
    popup.add quit

    tray_icon.popup_menu = popup

    show.add_action_listener do |evt|
      frame.state = java.awt.Frame::NORMAL
    end
    quit.add_action_listener do |evt|
      java.lang.System.exit 0
    end

    tray = java.awt.SystemTray.getSystemTray
    tray.add tray_icon
  end

end