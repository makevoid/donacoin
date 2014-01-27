class Donacoin::UI

  class SettingsDialog < JDialog
    include_package 'javax.swing'
    include Profligacy

    attr_reader :ui

    MAX_THREADS = Utils.max_threads

    def initialize(frame, modal)

      super frame, modal
      layout = "
       [ user_label               ]
       [ (150,30)*user_field      ]
       [ threads_label            ]
       [ (150,30)*threads_slider  ]
       [ save                     ]
      "

      settings = Settings.instance
      @threads = settings.threads

      @ui = Swing::LEL.new(JFrame, layout) do |c, i|
        c.user_label = JLabel.new "Username:"
        c.user_field = @user_field = JTextField.new settings.username
        c.threads_label = @threads_label = JLabel.new "Threads (#{@threads}):"
        c.threads_slider = @threads_slider = JSlider.new 1, MAX_THREADS, @threads
        c.save = @save_button = JButton.new "Save"

        i.user_field      = { action: method(:update_user)    }
        i.threads_slider  = { change: method(:threads_slider) }
        i.save            = { action: method(:save)           }
      end

      frame = @ui.build args: "Settings"
      frame.location_relative_to = nil
    end

    def save(type, event)
      settings = Settings.instance
      settings.username = @user_field.text
      settings.threads  = @threads_slider.value
      settings.prefs_save
    end

    def threads_slider(type, event)
      @threads = @threads_slider.value
      @threads_label.text = "Threads (#{@threads}):"
      Settings.instance.threads = @threads
      restart_miner_message
    end

    def update_user(type, event)
      @username = @user_field.text
      Settings.instance.username = @username
      restart_miner_message
    end

    def restart_miner_message
      puts "TODO: send restart message to miner"
    end
  end
end