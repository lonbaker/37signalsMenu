class JournalEntryController
  class << self
    def instances
      @instances ||= []
    end
  end

  attr_accessor :window, :textView, :button, :value
  
  def awakeFromNib
    NSApp.arrangeInFront(nil)
    NSApp.activateIgnoringOtherApps(true)
    window.makeKeyAndOrderFront(nil)
    textView.font = NSFont.fontWithName("Lucida Grande", size: 14)

    JournalEntryController.instances.push(self)
  end
  
  def windowWillClose(notification)
    JournalEntryController.instances.delete(self)
  end

  def textDidChange(notification)
    NSLog("text did change")
  end
  
  def textDidEndEditing(notification)
    NSLog("text did end editing")
  end
  
  def addJournalEntry(sender)
    NSLog("add journal entry")
  end
end
