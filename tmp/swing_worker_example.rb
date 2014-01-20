## swing worker example taken from jruby cookbook


class MySwingWorker < javax.swing.SwingWorker

  attr_accessor :button

  def doInBackground
    10.times do
      puts "thread #{self.hashCode} working"
      sleep(1)
    end
    self.button.text = "Completed"
  end

end

def vai(start)
  sw = MySwingWorker.new
  sw.button = start
  sw.execute
end


include Java
import javax.swing.JFrame
frame = JFrame.new "Swing Worker"
frame.default_close_operation = JFrame::EXIT_ON_CLOSE
start = javax.swing.JButton.new("start")
#define the function using a block

start.add_action_listener do |evt|
  vai(start)
end

frame.add start
frame.pack
frame.visible = true