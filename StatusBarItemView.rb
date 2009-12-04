class StatusBarItemView < NSView
  attr_accessor :menuController, :statusBarItem
  
  def initWithFrame(frame)
    NSNotificationCenter.defaultCenter.addObserver(self, selector: "applicationDidActivate:", name: NSApplicationDidBecomeActiveNotification, object: nil)
    @active = false
    @images = {
      true  => NSImage.imageNamed("MenuOn"),
      false => NSImage.imageNamed("MenuOff")
    }
    super
  end
  
  def drawRect(rect)
    statusBarItem.drawStatusBarBackgroundInRect(bounds, withHighlight: @active)
    @images[@active].drawAtPoint(NSMakePoint(4, 0), fromRect: NSZeroRect, operation: NSCompositeSourceOver, fraction: 1.0)
  end
  
  def mouseDown(event)
    if NSApp.isActive
      showMenu
    else
      NSApp.arrangeInFront(nil)
      NSApp.activateIgnoringOtherApps(true)
      @waitingForActivation = true
    end
  end
  
  def applicationDidActivate(notification)
    if @waitingForActivation
      @waitingForActivation = false
      showMenu
    end
  end

  def showMenu
    menu.delegate = self
    menuController.menuWillOpen(menu)
    statusBarItem.popUpStatusItemMenu(menu)
    self.needsDisplay = true
  end
  
  def menuWillOpen(menu)
    @active = true
    self.needsDisplay = true
  end
  
  def menuDidClose(menu)
    @active = false
    menu.delegate = nil
    self.needsDisplay = true
  end
end