//
//  Document.swift
//  DataText
//
//  Created by Mac Mini on 2/5/17.
//  Copyright © 2017 Armonia. All rights reserved.
//

import Cocoa

class Document: NSDocument {

    var windowController: NSWindowController?
    //var textView: NSTextView?
    //var table: DataTable?
    var content: String = ""  // From:to table.text
    
    override init() {
        super.init()
        Swift.print("Doc init")

        let app = NSApp.delegate as! AppDelegate
        if app.firstWindow {
            app.firstWindow = false
            openLastTable()
        }
    }

    override func close() {
        Swift.print("Close: ", self.fileURL)
        saveLastTableUrl()
        super.close()
    }
    
    override class func autosavesInPlace() -> Bool {
        return true
    }

    // Open last table
    func openLastTable() {
        Swift.print("Open last table")
        if let url = UserDefaults.standard.url(forKey: "lastTable") {
            let app = NSApp.delegate as! AppDelegate
            app.lastTable = url
            Swift.print("Opening file: ", url)
            try? self.read(from: url, ofType: "table")
            self.fileURL = url
        }
    }
    
    // Save last table url in UserDefaults
    func saveLastTableUrl() {
        Swift.print("Save last table url")
        if let url = self.fileURL {
            UserDefaults.standard.set(url, forKey: "lastTable")
            Swift.print("Saving url: ", url)
        }
    }
    
    // Open
    override func read(from data: Data, ofType typeName: String) throws {
        //Swift.print("Open: ", typeName)
        //Swift.print("File: ", self.fileURL)

        if let text = String(data: data, encoding: .utf8) {
            content = text
            //Swift.print("Text: \n", text)
        } else {
            Swift.print("Error reading file")
            throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        }
    }
    
    // Save
    override func data(ofType typeName: String) throws -> Data {
        Swift.print("Save: ", typeName)

        /*
        guard let text = textView?.string else {
            debugPrint("No text for saving?")
            throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        }
        */
        
        guard let viewController = windowController?.contentViewController as? ViewController else {
            Swift.print("No text for saving?")
            throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        }
        
        let text = viewController.tableController.table.text
        
        // TODO: Somewhere save fileURL to UserDefaults
        Swift.print("Saving text to ", self.fileURL)

        if let data = text.data(using: .utf8) {
            return data
        } else {
            Swift.print("No data for saving?")
            throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        }
    }
    
    
    // Assign content to view
    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: "Document Window Controller") as! NSWindowController
        self.addWindowController(windowController)
        
        // Custom code
        self.windowController = windowController
        //Swift.print("WC added")
        
        if let viewController = windowController.contentViewController as? ViewController {
            //textView = viewController.textView
            //textView?.string = content
            //self.table = viewController.tableController.table
            viewController.tableController.load(content)
            viewController.showRecordCount()
            //Swift.print("TextView added")
        }
    }
    
    /*
    override func save(_ sender: Any?) {
        //saveUserDefault()
        Swift.print("Save: ", self.fileURL)
        super.save(sender)
    }
    */
    
/*
    override func awakeFromNib() {
        debugPrint("Awakening...")
    }

    override func windowControllerDidLoadNib(_ windowController: NSWindowController) {
        super.windowControllerDidLoadNib(windowController)
        debugPrint("WC Loaded")
        if let vc = windowController.contentViewController as? ViewController {
            debugPrint("VC Loaded")
            textView = vc.textView
            textView?.string = content
        } else {
            debugPrint("VC not loaded yet")
        }
    }

    override func read(from url: URL, ofType typeName: String) throws {
        do {
            content = try String(contentsOf: url, encoding: .utf8)
        } catch {
            debugPrint("Error: ", error)
            throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        }
    }
    
    override func write(to url: URL, ofType typeName: String) throws {
        do {
            try textView?.string?.write(to: url, atomically: false, encoding: .utf8)
        } catch {
            debugPrint("Error: ", error)
            throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        }
    }
 */
}

