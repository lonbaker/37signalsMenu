class MenuController
  attr_accessor :menu
  attr_accessor :statusMenuItem
  attr_accessor :newJournalEntryMenuItem
  attr_accessor :progressIndicator
  attr_accessor :statusInitializationView
  attr_accessor :statusManipulationView
  attr_accessor :statusInOut
  attr_accessor :statusTextField
  
  attr_reader :identity
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
    controller = JournalEntryController.new
    controller.identity = identity
    NSBundle.loadNibNamed("JournalEntry", owner: controller)
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
    @journalStatus.userID = identity.userID
    @journalStatus.load
  end
  
  def backpackResource(resource, receivedRemoteAttributes: attributes)
    if resource == identity
      startLoadingJournalStatus
      newJournalEntryMenuItem.enabled = true
      
    elsif resource == journalStatus
      statusTextField.stringValue = journalStatus.displayMessage
      statusInOut.selectedSegment = journalStatus.in? ? 0 : 1
      updateStatusView
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
      updateStatusView
      statusTextField.selectText(0)
    else
      journalStatus.out!
      updateStatusView
      menu.cancelTracking
    end
  end
  
  def updateStatusView
    if journalStatus.in?
      statusTextField.enabled = true
      statusManipulationView.frameSize = [300, 88]
    else
      statusTextField.enabled = false
      statusManipulationView.frameSize = [300, 22]
    end
    
    statusMenuItem.view = statusManipulationView
    statusManipulationView.display
  end
end
