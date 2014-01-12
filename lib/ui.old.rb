require 'profligacy/swing'
require 'profligacy/lel'


class Donacoin::UI
  include_package 'javax.swing'
  include Profligacy

  require_relative 'textarea_formatter'

  def initialize
    layout = "
     [ <label_ids ]
     [ (320,60)*ids_pane ]
     [ <label_type ]
     [ <types_panel ]
     [ (320,32)*status ]
     [ progress ]
     [ >submit ]
    "
    layout_type = "[ type_contract | type_decision ]"

    @ui = Swing::LEL.new(JFrame, layout) do |c, i|
      c.label_ids   = JLabel.new "Numbers:"
      @ids = JTextArea.new
      c.ids_pane         = JScrollPane.new @ids
      # c.ids.setMaximumSize c.ids.getPreferredSize()
      c.label_type  = JLabel.new "Type:"
      c.status      = JLabel.new " "
      @progress = c.progress    = JProgressBar.new
      @progress.indeterminate = true
      @progress.visible = false

      @submit = c.submit      = JButton.new "Download"

      c.types_panel = Swing::LEL.new(JPanel, layout_type) do |c,i|
        c.type_contract = JRadioButton.new "Contract", true
        c.type_decision = @type_decision = JRadioButton.new "Decision"
        @btn_group = ButtonGroup.new
        @btn_group.add c.type_contract
        @btn_group.add c.type_decision
      end.build :auto_create_container_gaps => false

      i.submit = { action: method(:submit) }
    end

    @ids.getDocument().addDocumentListener TextareaFormatter.new(@ids)

    @ui.build(args: "CRIS Downloader [Eptisa]").default_close_operation = JFrame::EXIT_ON_CLOSE

    @core = nil
    @submit.enabled = false
    status "logging in... (wait please)"
    Thread.new {
      @core = Core.new
      @submit.enabled = true
    }

    Thread.new {
      loop do 
        begin
          status @core.status if @core && @core.status
          sleep 1
        rescue Exception => e
          puts "Unhandled exception in Thread:"
          puts e
          puts e.message
        end
      end
    }
  end

  def radio_selection
    @type_decision.selected? ? "decision" : "contract"
  end

  def ids
    @ids.text
  end

  def submit(type, event)
    # Core.download ids, radio_selection
    @core.load(ids, radio_selection)

    if ids == ""
      status "please enter some #{radio_selection} numbers separated by spaces"
      return
    end

    download

    @progress.visible = true
    status "Connecting..."
    event.source.enabled = false
  end

  def download
    Thread.new {
      begin
        connection_test
      rescue Timeout::Error => e
        status "Error: #{OutsideVPNError.new.message}"
      rescue Exception => e
        puts "Unhandled exception in Thread:"
        puts e
        puts e.message
      else
        status "downloading #{details}..."
        @core.download
        status "download finished of #{details}"
      ensure
        @progress.visible = false
        @submit.enabled = true
      end
    }
  end

  def details
    "#{radio_selection}(s) #{ids}"
  end

  def status(message)
    @ui.status.text = "<html><center>#{message}</center></html>"
  end

  private

  def connection_test
    http = Net::HTTP.new "158.167.211.53", 6081
    http.open_timeout = 5 # in seconds
    http.read_timeout = 5 # in seconds
    http.request Net::HTTP::Get.new("/")
  end
end

# was it useful? boh!
#
# def persist_window
#   event_thread = nil
#   SwingUtilities.invokeAndWait { event_thread = java.lang.Thread.currentThread }
#   event_thread.join
# end