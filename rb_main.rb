#
# rb_main.rb
# 37signals Menu
#
# Created by Sam Stephenson on 11/29/09.
# Copyright 37signals 2009. All rights reserved.
#

RESOURCES_PATH = File.dirname(__FILE__)
BUNDLED_STDLIB_PATH = File.join(RESOURCES_PATH, "../Frameworks/MacRuby.framework/Versions/Current/usr/lib/ruby/1.9.0")
$:.unshift(BUNDLED_STDLIB_PATH)

# Loading the Cocoa framework. If you need to load more frameworks, you can
# do that here too.
framework "Cocoa"

require "BackpackRequest"
require "BackpackResource"
require "Identity"
require "JournalEntry"
require "JournalStatus"
require "StatusBarItemView"
require "StatusView"
require "MenuController"
require "JournalEntryController"

BackpackRequest.accountName = NSBundle.mainBundle.objectForInfoDictionaryKey("BackpackAccountName")

# Starting the Cocoa main loop.
NSApplicationMain(0, nil)
