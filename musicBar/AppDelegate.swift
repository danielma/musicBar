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

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let dnc = NSDistributedNotificationCenter.defaultCenter()
        dnc.addObserver(self, selector: Selector("updateTrackInfo:"), name: "com.apple.iTunes.playerInfo", object: nil)
        
        menu.addItem(NSMenuItem(title: "", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Open iTunes", action: Selector("openItunes:"), keyEquivalent: "o"))
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(NSMenuItem(title: "Quit", action: Selector("terminate:"), keyEquivalent: "q"))
        
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
        if let information = notification.userInfo {
            let album = getFromAnything(information, key: "Album")
            let track = getFromAnything(information, key: "Name")
            let artist = getFromAnything(information, key: "Artist")
            let playerState = getFromAnything(information, key: "Player State")
            
            // print("notification: \(information)")
            
            let trackInfo = TrackInfo(album: album, artist: artist, track: track, playerState: playerState)
            updateMenuTextWithTrackInfo(trackInfo)
            updateMenuItemsWithTrackInfo(trackInfo)
        }
    }
    
    func updateMenuTextWithTrackInfo(info: TrackInfo) {
        if let button = statusItem.button {
            let statusIcon = info.playerState == "Playing" ? "▶" : "❚❚"
            button.title = "\(statusIcon) \(info.track) - \(info.artist)"
        }
    }
    
    func updateMenuItemsWithTrackInfo(info: TrackInfo) {
        menu.removeItemAtIndex(0)
        menu.insertItem(NSMenuItem(title: "Album: \(info.album)", action: nil, keyEquivalent: ""), atIndex: 0)
    }
    
    func openItunes(sender: AnyObject) {
        NSWorkspace.sharedWorkspace().launchApplication("iTunes.app")
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

