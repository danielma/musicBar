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
  
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
  let menu = NSMenu()
  static let documentsUrl = FileManager.default.urls(for: FileManager.SearchPathDirectory.musicDirectory, in: .userDomainMask)[0] as URL
  static let fileUrl = documentsUrl.appendingPathComponent(".musicBar")
  var currentTrack = TrackInfo(album: "", artist: "", track: "", playerState: "")

  
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    let dnc = DistributedNotificationCenter.default()
    dnc.addObserver(self, selector: #selector(updateTrackInfo(_:)), name: NSNotification.Name(rawValue: "com.apple.iTunes.playerInfo"), object: nil)
    dnc.addObserver(self, selector: #selector(updateTrackInfo(_:)), name: NSNotification.Name(rawValue: "com.spotify.client.PlaybackStateChanged"), object: nil)
    
    menu.addItem(NSMenuItem(title: "", action: nil, keyEquivalent: ""))
    menu.addItem(NSMenuItem(title: "Open iTunes", action: #selector(openItunes(_:)), keyEquivalent: "o"))
    menu.addItem(NSMenuItem(title: "Lookup lyrics on Genius.com", action: #selector(searchGenius(_:)), keyEquivalent: "l"))
    menu.addItem(NSMenuItem.separator())
    menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApp.terminate(_:)), keyEquivalent: "q"))
    
    statusItem.menu = menu
  }
  
  func applicationWillTerminate(_ aNotification: Notification) {
    let dnc = DistributedNotificationCenter.default()
    dnc.removeObserver(self, name: NSNotification.Name(rawValue: "com.apple.iTunes.playerInfo"), object: nil)
    dnc.removeObserver(self, name: NSNotification.Name(rawValue: "com.spotify.client.PlaybackStateChanged"), object: nil)
  }
  
  func printQuote(_ sender: AnyObject) {
    let quoteText = "Never put off until tomorrow what you can do the day after tomorrow."
    let quoteAuthor = "Mark Twain"
    
    print("\(quoteText) — \(quoteAuthor)")
  }
  
  func getFromAnything(_ anyObject: [AnyHashable: Any], key: String) -> String {
    let maybeValue = anyObject[key]
    
    if maybeValue == nil { return "" }
    
    return maybeValue as! String
  }
  
    @objc func updateTrackInfo(_ notification: Notification) {
    print(notification)
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

  func updateStatusFileWithTrackInfo(_ info: TrackInfo) {
    let str = "\(playerText(info))\n"
    
    // get URL to the the documents directory in the sandbox
    // write to it
    do {
      try str.write(to: AppDelegate.fileUrl, atomically: false, encoding: String.Encoding.utf8)
    } catch {
      // whatever
    }
  }

  func playerText(_ info: TrackInfo) -> String {
    let statusIcon = info.playerState == "Playing" ? "▶" : "❚❚"
    return "\(statusIcon) \(info.track) - \(info.artist)"
  }
  
  func updateMenuTextWithTrackInfo(_ info: TrackInfo) {
    if let button = statusItem.button {
      button.title = playerText(info)
    }
  }
  
  func updateMenuItemsWithTrackInfo(_ info: TrackInfo) {
    menu.removeItem(at: 0)
    menu.insertItem(NSMenuItem(title: "Album: \(info.album)", action: nil, keyEquivalent: ""), at: 0)
  }
  
    @objc func openItunes(_ sender: AnyObject) {
        NSWorkspace.shared.launchApplication("iTunes.app")
  }

    @objc func searchGenius(_ sender: AnyObject) {
    let searchQuery = "\(currentTrack.track) \(currentTrack.artist)".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
    if let searchQuery = searchQuery {
      let urlString = "https://duckduckgo.com/?q=!ducky+\(searchQuery)+site%3Agenius.com"
      let url = URL(string: urlString)
      if let unwrappedURL = url {
        NSWorkspace.shared.open(unwrappedURL)
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

