//
//  AppDelegate.swift
//  DataText
//
//  Created by Mac Mini on 2/5/17.
//  Copyright © 2017 Armonia. All rights reserved.
//

import Cocoa

/* Common definitions */

typealias Parameters  = Dictionary<String, Any>
typealias DataRecord  = Dictionary<String, Any>
typealias DataResults = [DataRecord]


/* App delegate */

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var firstWindow = true
    var lastTable: URL?  // Save for reopening next time
    
    override init() {
        print("Hello!")
        super.init()
        
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Three possible states: last file, no file, open file
        // print("App did finish loading")
        lastTable = UserDefaults.standard.url(forKey: "lastTable")
        let app = aNotification.object as! NSApplication
        
        if let vc = app.mainWindow?.contentViewController as? ViewController {
            if lastTable == nil {
                vc.loadSampleTable()
            } else {
                // Already loaded as first Document
            }
        } else {
            print("VC not loaded yet")
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        print("Goodbye!")
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

}

