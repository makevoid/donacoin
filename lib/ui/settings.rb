class Donacoin::UI

  class SettingsDialog < JDialog
    include_package 'javax.swing'
    include Profligacy

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

      @threads = Utils.cores_usable

      @ui = Swing::LEL.new(JFrame, layout) do |c, i|
        c.user_label = JLabel.new "Username:"
        c.user_field = @user_field = JTextField.new
        c.threads_label = @threads_label = JLabel.new "Threads (#{@threads}):"
        c.threads_slider = @threads_slider = JSlider.new 1, MAX_THREADS
        c.save = @save_button = JButton.new "Save"

        i.user_field      = { action: method(:update_user)    }
        i.threads_slider  = { change: method(:threads_slider) }
        i.save            = { action: method(:save)           }
      end


      @ui.build args: "Settings"



    end

    def save(type, event)
      puts @ui.container.dispose
    end

    def threads_slider(type, event)
      @threads = @threads_slider.value
      @threads_label.text = "Threads (#{@threads}):"
      Settings.instance.threads = @threads
      puts "TODO: restart miner"
    end

    def update_user(type, event)
      @username = @user_field.text
      puts "TODO"
      puts @username
    end
  end
end