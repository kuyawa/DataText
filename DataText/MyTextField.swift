//
//  MyTextField.swift
//  DataText
//
//  Created by Mac Mini on 2/9/17.
//  Copyright © 2017 Armonia. All rights reserved.
//

import Cocoa
import Foundation

class MyTextField: NSTextField, NSTextFieldDelegate {
    // The worst sourcery ever
    // Needed to know when a cell was being entered even if not edited
    // So we could trap on key up and select same column but prev/next row
    /*
    override func validateProposedFirstResponder(_ responder: NSResponder, for event: NSEvent?) -> Bool {
        if let cellId = superview?.identifier,
            let tableController = (superview?.superview?.superview as? TableView)?.delegate as? TableController {
            tableController.activeColumnId = cellId
            return true
        }
        
        return super.validateProposedFirstResponder(responder, for: event)
    }
    */

    override func becomeFirstResponder() -> Bool {
        //Swift.print("becomeFirstResponder")
        let ok = super.becomeFirstResponder()
        
        guard let cellId = superview?.identifier else {
            Swift.print("No cellId")
            return ok
        }
        
        guard let tableController = (superview?.superview?.superview as? NSTableView)?.delegate as? TableController else {
            Swift.print("No tableController ", superview?.superview?.superview?.className)
            return ok
        }
        
        //Swift.print("Assigned ", cellId)
        tableController.activeColumnId = cellId
        tableController.isEditing = true
        
        return ok
    }
}
