class JournalEntryController
  class << self
    def instances
      @instances ||= []
    end
  end

  attr_accessor :identity, :window, :textView, :button, :value, :journalEntry
  
  def awakeFromNib
    NSApp.arrangeInFront(nil)
    NSApp.activateIgnoringOtherApps(true)
    window.makeKeyAndOrderFront(nil)
    textView.font = NSFont.fontWithName("Lucida Grande", size: 14)

    self.journalEntry = JournalEntry.resourceWithDelegate(self)
    JournalEntryController.instances.push(self)
  end
  
  def windowWillClose(notification)
    JournalEntryController.instances.delete(self)
  end

  def textDidChange(notification)
  end
  
  def textDidEndEditing(notification)
  end
  
  def contentsOfMessageField
    textView.textStorage.string
  end
  
  def addJournalEntry(sender)
    window.close
    journalEntry.identity = identity
    journalEntry.update(body: contentsOfMessageField)
  end

  def backpackResource(resource, receivedRemoteAttributes: attributes)
    NSSound.soundNamed("Journal Entry Saved").play
  end
end
