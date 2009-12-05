class StatusView < NSView
  def viewDidMoveToWindow
    if window
      startTimer
    else
      stopTimer
    end
  end
  
  def startTimer
    date = NSDate.dateWithTimeIntervalSinceNow(0)
    @timer = NSTimer.alloc.initWithFireDate(date, interval: 1.0, target: self, selector: "timer:", userInfo: nil, repeats: true)
    NSRunLoop.currentRunLoop.addTimer(@timer, forMode: NSEventTrackingRunLoopMode)
  end
  
  def timer(sender)
    NSRunLoop.mainRunLoop.runUntilDate(NSDate.dateWithTimeIntervalSinceNow(0.01))
  end
  
  def stopTimer
    @timer.invalidate
  end
end
