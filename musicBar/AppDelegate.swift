//
//  AppDelegate.swift
//  musicBar
//
//  Created by Daniel Ma on 2/20/16.
//  Copyright © 2016 Daniel Ma. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  
  @IBOutlet weak var window: NSWindow!
  
  let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
  let menu = NSMenu()
  static let documentsUrl = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.MusicDirectory, inDomains: .UserDomainMask)[0] as NSURL
  static let fileUrl = documentsUrl.URLByAppendingPathComponent(".musicBar")
  var currentTrack = TrackInfo(album: "", artist: "", track: "", playerState: "")

  
  func applicationDidFinishLaunching(aNotification: NSNotification) {
    let dnc = NSDistributedNotificationCenter.defaultCenter()
    dnc.addObserver(self, selector: #selector(updateTrackInfo(_:)), name: "com.apple.iTunes.playerInfo", object: nil)
    
    menu.addItem(NSMenuItem(title: "", action: nil, keyEquivalent: ""))
    menu.addItem(NSMenuItem(title: "Open iTunes", action: #selector(openItunes(_:)), keyEquivalent: "o"))
    menu.addItem(NSMenuItem(title: "Lookup lyrics on Genius.com", action: #selector(searchGenius(_:)), keyEquivalent: "l"))
    menu.addItem(NSMenuItem.separatorItem())
    menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApp.terminate(_:)), keyEquivalent: "q"))
    
    statusItem.menu = menu
  }
  
  func applicationWillTerminate(aNotification: NSNotification) {
    let dnc = NSDistributedNotificationCenter.defaultCenter()
    dnc.removeObserver(self, name: "com.apple.iTunes.playerInfo", object: nil)
  }
  
  func printQuote(sender: AnyObject) {
    let quoteText = "Never put off until tomorrow what you can do the day after tomorrow."
    let quoteAuthor = "Mark Twain"
    
    print("\(quoteText) — \(quoteAuthor)")
  }
  
  func getFromAnything(anyObject: [NSObject : AnyObject], key: String) -> String {
    let maybeValue = anyObject[key]
    
    if maybeValue == nil { return "" }
    
    return maybeValue as! String
  }
  
  func updateTrackInfo(notification: NSNotification) {
    guard let information = notification.userInfo else { return }

    let album = getFromAnything(information, key: "Album")
    let track = getFromAnything(information, key: "Name")
    let artist = getFromAnything(information, key: "Artist")
    let playerState = getFromAnything(information, key: "Player State")
    
    // print("notification: \(information)")
    
    let trackInfo = TrackInfo(album: album, artist: artist, track: track, playerState: playerState)
    currentTrack = trackInfo
    updateMenuTextWithTrackInfo(trackInfo)
    updateMenuItemsWithTrackInfo(trackInfo)
    updateStatusFileWithTrackInfo(trackInfo)
  }

  func updateStatusFileWithTrackInfo(info: TrackInfo) {
    let str = playerText(info)
    
    // get URL to the the documents directory in the sandbox
    // write to it
    do {
      try str.writeToURL(AppDelegate.fileUrl, atomically: false, encoding: NSUTF8StringEncoding)
    } catch {
      // whatever
    }
  }

  func playerText(info: TrackInfo) -> String {
    let statusIcon = info.playerState == "Playing" ? "▶" : "❚❚"
    return "\(statusIcon) \(info.track) - \(info.artist)"
  }
  
  func updateMenuTextWithTrackInfo(info: TrackInfo) {
    if let button = statusItem.button {
      button.title = playerText(info)
    }
  }
  
  func updateMenuItemsWithTrackInfo(info: TrackInfo) {
    menu.removeItemAtIndex(0)
    menu.insertItem(NSMenuItem(title: "Album: \(info.album)", action: nil, keyEquivalent: ""), atIndex: 0)
  }
  
  func openItunes(sender: AnyObject) {
    NSWorkspace.sharedWorkspace().launchApplication("iTunes.app")
  }

  func searchGenius(sender: AnyObject) {
    let searchQuery = "\(currentTrack.track) \(currentTrack.artist)".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
    if let searchQuery = searchQuery {
      let urlString = "https://duckduckgo.com/?q=!ducky+\(searchQuery)+site%3Agenius.com"
      let url = NSURL(string: urlString)
      if let unwrappedURL = url {
        NSWorkspace.sharedWorkspace().openURL(unwrappedURL)
      }
    }
  }
}

class TrackInfo {
  var album: String
  var artist: String
  var track: String
  var playerState: String
  
  init(album: String, artist: String, track: String, playerState: String) {
    self.album = album
    self.artist = artist
    self.track = track
    self.playerState = playerState
  }
}

