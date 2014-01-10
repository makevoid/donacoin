class TextareaFormatter

  def initialize(area)
    @area = area
  end

  def textareaUpdate(event)
    SwingUtilities.invokeLater do
      @updating = true
      text = @area.text.gsub(/\s+/, ' ').gsub(",", '')
      @area.text = text
    end
  end

  def insertUpdate(event)
    if @updating
      @updating = false
    else
      textareaUpdate event
    end
  end

  def changedUpdate(event)
    # do nothing
  end

  def removeUpdate(event)
    # do nothing
  end

end