//
//  ViewController.swift
//  DataText
//
//  Created by Mac Mini on 2/5/17.
//  Copyright © 2017 Armonia. All rights reserved.
//

import Cocoa


class ViewController: NSViewController {

    enum TabPanel {
        case Browse, Schema, Text
    }

    var currentTab = TabPanel.Browse
    var currentColumn = 0
    var tableController = TableController()
    
    @IBOutlet      var textView   : NSTextView!
    @IBOutlet weak var textStatus : NSTextField!
    @IBOutlet weak var tableView  : NSTableView!
    
    @IBAction func onInsertRecord(_ sender: AnyObject) {
        tableController.insertRecord()
        showRecordCount()
    }
    
    @IBAction func onRemoveRecord(_ sender: AnyObject) {
        tableController.removeRecord()
        showRecordCount()
    }
    
    @IBAction func onDuplicateRecord(_ sender: AnyObject) {
        tableController.duplicateRecord()
        showRecordCount()
    }
    
    @IBAction func onInsertColumn(_ sender: AnyObject) {
        tableController.insertColumn()
    }
    
    @IBAction func onRemoveColumn(_ sender: AnyObject) {
        tableController.removeColumn()
    }
    
    @IBAction func onAlignLeft(_ sender: AnyObject) {
        tableController.alignLeft()
    }
    
    @IBAction func onAlignCenter(_ sender: AnyObject) {
        tableController.alignCenter()
    }
    
    @IBAction func onAlignRight(_ sender: AnyObject) {
        tableController.alignRight()
    }
    
    @IBAction func onChangeDataText(_ sender: AnyObject) {
        tableController.changeDataText()
    }
    
    @IBAction func onChangeDataInt(_ sender: AnyObject) {
        tableController.changeDataInt()
    }
    
    @IBAction func onChangeDataReal(_ sender: AnyObject) {
        tableController.changeDataReal()
    }
    
    @IBAction func onChangeDataDate(_ sender: AnyObject) {
        tableController.changeDataDate()
    }
    
    @IBAction func onChangeDataTime(_ sender: AnyObject) {
        tableController.changeDataTime()
    }
    
    @IBAction func onChangeDataBool(_ sender: AnyObject) {
        tableController.changeDataBool()
    }
    
    override func keyUp(with event: NSEvent) {
        //print("View key pressed: ", event.keyCode)

        if tableController.isEditing {
            switch event.keyCode {
            case 126 /* up    */ : tableController.editCellUp()
            case 125 /* dn    */ : tableController.editCellDown()
            case  53 /* esc   */ : tableController.isEditing = false
            case  36 /* enter */ : tableController.isEditing = false
            default : super.keyUp(with: event)
            }
        } else {
            super.keyUp(with: event)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    func initialize() {
        tableController.tableView = tableView
        //print("Ready")
    }

    func loadTable(_ url: URL) {
        //print("VC Load table: ", url)
        // TODO: Use document loader?
        let text = try? String(contentsOf: url, encoding: .utf8)
        tableController.load(text ?? "")
        showRecordCount()
    }
    
    func loadSampleTable() {
        //print("VC Load sample table")
        tableController.loadSample()
        showRecordCount()
    }
    
    /*
    func prepareTable() {
        tableController = TableController()
        tableController.tableView = tableView
        tableController.getSchema()  // tablename.schema
        tableController.getRecords() // tablename.table
        tableController.makeTable()
        tableController.reload()
        //tableController.onSelection(selectTable)
        showRecordCount()
    }
    */
    
    func showRecordCount() {
        let count = tableController.table.records.count
        let word  = count == 1 ? "record" : "records"
        showStatus("\(count) \(word)")
    }

    func showStatus(_ text: String) {
        textStatus.stringValue = text
    }
    

}

