//
//  TableView.swift
//  DataText
//
//  Created by Mac Mini on 2/9/17.
//  Copyright © 2017 Armonia. All rights reserved.
//

import Cocoa
import Foundation


// NOT USED. REMOVE.
class TableView: NSTableView, NSTableViewDelegate {
    
    /*
    override func keyUp(with event: NSEvent) {
        Swift.print("Key up in table")

        if let tc = (self.delegate as? TableController) {
            switch event.keyCode {
            case 126 /* up */ : tc.editCellUp()
            case 125 /* dn */ : tc.editCellDown()
            default : super.keyUp(with: event)
            }
        }
    }
    */

    /*
    func tableView(_ tableView: NSTableView, shouldEdit tableColumn: NSTableColumn?, row: Int) -> Bool {
        return true
    }
    */
    /*
    func tableView(_ tableView: NSTableView, shouldEdit tableColumn: NSTableColumn?, row: Int) -> Bool {
        Swift.print("Should edit column?")
        if let cellId = tableColumn?.identifier {
            let tc = tableView.delegate as! TableController
            tc.activeColumnId = cellId
            Swift.print("OK ", cellId)
        }
        return true
    }
    */
    

    // From here down they're not being called
    
    override func textDidEndEditing(_ notification: Notification) {
        Swift.print("Text did end editing")
    }
    
    override func controlTextDidEndEditing(_ obj: Notification) {
        Swift.print("ControlTextDidEndEditing")
    }
    
    override func controlTextDidChange(_ obj: Notification) {
        Swift.print("controlTextDidChange")
    }
    
    override func controlTextDidBeginEditing(_ obj: Notification) {
        Swift.print("controlTextDidBeginEditing")
    }
    
    override func textShouldBeginEditing(_ textObject: NSText) -> Bool {
        Swift.print("textShouldBeginEditing")
        return true
    }
    
    override func textDidChange(_ notification: Notification) {
        Swift.print("textDidChange")
    }
    
}
