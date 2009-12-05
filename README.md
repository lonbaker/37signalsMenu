37signals Menu
==============

![37signals Menu screenshot](http://sstephenson.s3.amazonaws.com/public/37signals-menu.png)

An experimental Mac OS X desktop client for [37signals' Backpack Journal](http://backpackit.com/tour#journal) that lets you quickly change your status message, mark yourself as in or out, and add journal entries from the menu bar.

Requires MacRuby 0.5 beta 2.

## Notes

37signals Menu authenticates using the system's shared cookie storage, so make sure you're logged into your Backpack account with Safari first.

You'll need to change the value of the `BackpackAccountName` property in `Info.plist` to your Backpack account's subdomain before building.
