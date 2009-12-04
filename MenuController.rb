class MenuController
  attr_accessor :menu
  attr_accessor :statusMenuItem
  attr_accessor :progressIndicator
  attr_accessor :statusInitializationView
  attr_accessor :statusManipulationView
  attr_accessor :statusInOut
  attr_accessor :statusTextField
  
  attr_reader :identity
  attr_reader :userID
  attr_reader :journalStatus
  
  def awakeFromNib
    @statusBarItem = NSStatusBar.systemStatusBar.statusItemWithLength(NSSquareStatusItemLength)
    CFRetain(@statusBarItem)

    @statusBarItemView = StatusBarItemView.new
    @statusBarItemView.menuController = self
    @statusBarItemView.statusBarItem = @statusBarItem
    @statusBarItemView.menu = menu
    @statusBarItem.view = @statusBarItemView

    startLoading
  end
  
  def menuWillOpen(menu)
    progressIndicator.startAnimation(self)
    startLoading
  end
  
  def newJournalEntry(sender)
    NSBundle.loadNibNamed("JournalEntry", owner: JournalEntryController.new)
  end
  
  def openJournal(sender)
    url = NSURL.URLWithString("https://#{BackpackRequest.accountName}.backpackit.com/journal_entries")
    NSWorkspace.sharedWorkspace.openURL(url)
  end
  
  def startLoading
    if !identity
      startLoadingIdentity
      statusMenuItem.view = statusInitializationView
    end
  end
  
  def startLoadingIdentity
    @identity = Identity.resourceWithDelegate(self)
    @identity.load
  end
  
  def startLoadingJournalStatus
    @journalStatus = JournalStatus.resourceWithDelegate(self)
    @journalStatus.userID = userID
    @journalStatus.load
  end
  
  def backpackResource(resource, didChangeAttributesTo: attributes)
    NSLog("backpackResource:didChangeAttributesTo: #{attributes.inspect}")
    if resource == identity
      @userID = identity.userID
      startLoadingJournalStatus
      
    elsif resource == journalStatus
      statusTextField.stringValue = journalStatus.displayMessage
      statusInOut.selectedSegment = journalStatus.in? ? 0 : 1
      adjustStatusTextField
      statusMenuItem.view = statusManipulationView
    end
  end
  
  def backpackResource(resource, failedToLoadWithError: error)
    if resource == identity
      @identity = nil
    end
  end
  
  def controlTextDidChange(notification)
    @statusTextField = notification.object
  end
  
  def controlTextDidEndEditing(notification)
    @statusTextField = notification.object
    if statusTextField.stringValue != journalStatus.displayMessage
      journalStatus.update(message: statusTextField.stringValue)
    end
    menu.cancelTracking
  end
  
  def inOutClicked(sender)
    if sender.selectedSegment == 0
      journalStatus.in!
      adjustStatusTextField(true)
      statusTextField.selectText(0)
    else
      journalStatus.out!
      adjustStatusTextField(false)
      menu.cancelTracking
    end
  end
  
  def adjustStatusTextField(editable = journalStatus.in?)
    statusTextField.enabled = editable
    statusTextField.editable = editable
    statusTextField.selectable = editable
  end
end
