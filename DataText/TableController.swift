//
//  TableController.swift
//  DataText
//
//  Created by Mac Mini on 2/6/17.
//  Copyright © 2017 Armonia. All rights reserved.
//

import Cocoa
import Foundation

// removed delegates: NSTextFieldDelegate, NSControlTextEditingDelegate
class TableController: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    
    var table     = DataTable()
    var tableView : NSTableView?
    var activeColumnId = ""
    var activeColumn = 0
    var activeRow = 0
    var isEditing = false
    

    func load(_ text: String) {
        // Text sent from Document.content on opening file
        table.text = text
        makeTable()
        reload()
    }
    
    func loadSample() {
        let url  = Bundle.main.url(forResource: "Sample", withExtension: "table")
        let text = try? String(contentsOf: url!)
        table.text = text ?? ""
        makeTable()
        reload()
    }
    
    /*
    func save() {
        // TODO: parse table.records into text and send to Document.save
    }
    */
   
    func getSchema() {
        //fields = table.fields()
        //print("Fields schema: ", fields)
        //schema.parseFields(fields)
    }
    
    func getRecords() {
        //records = table.records
        //print("Records: ", records)
    }
    
    func clear() {
        clearRows()
        clearColumns()
    }
    
    func clearRows() {
        if let last = tableView?.numberOfRows {
            //let range = NSRange(location: 0, length: last)
            let all = IndexSet(integersIn: 0 ..< last)
            tableView?.removeRows(at: all, withAnimation: .slideUp)
        }
    }
    
    func clearColumns() {
        if let view = tableView {
            for col in view.tableColumns {
                view.removeTableColumn(col)
            }
        }
    }
    
    func makeTable() {
        //print("Make table")
        guard let tableView = tableView else { print("No tableView"); return }
        
        clearRows()
        clearColumns()
        
        var nib = NSNib(nibNamed: "BaseTableCell", bundle: .main)
        
        for field in table.schema.fields {
            let name = field.name
            var size = field.width
            if size <  80 { size =  80 }  // Min
            if size > 300 { size = 300 }  // Max
            
            let col = NSTableColumn(identifier: name)
            col.headerCell.title = name
            col.headerCell.alignment = .center
            col.width = CGFloat(size)
            if col.width < 1.0 { col.width = 100.0 }
            col.isEditable = true
            tableView.addTableColumn(col)
            
            switch field.base {
            case .Text    : nib = NSNib(nibNamed: "BaseTableCell"   , bundle: .main)
            case .Integer : nib = NSNib(nibNamed: "NumericTableCell", bundle: .main)
            case .Real    : nib = NSNib(nibNamed: "NumericTableCell", bundle: .main)
            case .Date    : nib = NSNib(nibNamed: "BaseTableCell"   , bundle: .main) // TODO: Date table cell
            case .Time    : nib = NSNib(nibNamed: "BaseTableCell"   , bundle: .main) // TODO: Date table cell
            case .Bool    : nib = NSNib(nibNamed: "BoolTableCell"   , bundle: .main)
            case .Binary  : nib = NSNib(nibNamed: "BaseTableCell"   , bundle: .main) // Deprecated, use urls
            }

            tableView.register(nib, forIdentifier: name)
        }
        
        tableView.usesAlternatingRowBackgroundColors = true
        tableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        tableView.delegate   = self
        tableView.dataSource = self
        tableView.target     = self
        tableView.font       = NSFont.monospacedDigitSystemFont(ofSize: 12.0, weight: NSFontWeightRegular)
    }
    
    func reload() {
        tableView?.reloadData()
    }
    
    func refresh() {
        clear()
        makeTable()
        reload()
    }
    
    // Make an array [0,1,2,..nCols] of indexes
    func getColIndexes() -> IndexSet {
        let count = table.schema.fields.count
        let cols  = IndexSet(integersIn: 0..<count)
        
        return cols
    }
    
    func newRecord() -> DataRecord {
        var record = DataRecord()
        
        for field in table.schema.fields {
            record[field.name] = ""
        }
        
        return record
    }
    
    func insertRecord() {
        // TODO: Insert below current line, reorder line numbers
        let line = newRecord()
        table.records.append(line)
        let last = table.records.count - 1
        let cols: IndexSet = getColIndexes()
        tableView?.insertRows(at: [last], withAnimation: .slideDown)
        tableView?.reloadData(forRowIndexes: [last], columnIndexes: cols)
        tableView?.scrollRowToVisible(last)
        tableView?.selectRowIndexes([last], byExtendingSelection: false)
    }
    
    func removeRecord() {
        guard let selected = tableView?.selectedRow else { return }
        guard selected.inRange(0, table.records.count-1) else { return }
        table.records.remove(at: selected)
        tableView?.removeRows(at: [selected], withAnimation: .slideUp)
        var last = selected
        if last == table.records.count { last -= 1 } // last row removed, select previous
        tableView?.selectRowIndexes([last], byExtendingSelection: false)
        //let cols : IndexSet = [0,1,2,3,4]
        //tableView.reloadData(forRowIndexes: [selected], columnIndexes: cols)
    }
    
    func duplicateRecord() {
        guard let selected = tableView?.selectedRow else { return }
        guard selected.inRange(0, table.records.count-1) else { return }
        let line = table.records[selected]
        table.records.append(line)
        let last = table.records.count - 1
        let cols: IndexSet = getColIndexes()
        tableView?.insertRows(at: [last], withAnimation: .slideDown)
        tableView?.reloadData(forRowIndexes: [last], columnIndexes: cols)
        tableView?.scrollRowToVisible(last)
        tableView?.selectRowIndexes([last], byExtendingSelection: false)
    }

    func insertColumn() {
        print("Insert column...")
        guard let tableView = tableView else { print("No tableView"); return }

        var nib = NSNib(nibNamed: "BaseTableCell", bundle: .main)

        let n = table.schema.fields.count
        let field = TableField()
        field.name = "Column\(n+1)"
        field.base = .Text
        field.ordinal = n
        field.length = 20
        field.width = 100
        table.schema.fields.append(field)
        print("Col name: ", field.name)
        
        // Update records, add new column
        for (index, _) in table.records.enumerated() {
            table.records[index][field.name] = ""
        }
        
        let col = NSTableColumn(identifier: field.name)
        col.headerCell.title = field.name
        col.headerCell.alignment = .center
        col.width = CGFloat(field.width)
        col.isEditable = true
        tableView.addTableColumn(col)
        
        switch field.base {
        case .Text    : nib = NSNib(nibNamed: "BaseTableCell"   , bundle: .main)
        case .Integer : nib = NSNib(nibNamed: "NumericTableCell", bundle: .main)
        case .Real    : nib = NSNib(nibNamed: "NumericTableCell", bundle: .main)
        case .Date    : nib = NSNib(nibNamed: "BaseTableCell"   , bundle: .main) // TODO: Date table cell
        case .Time    : nib = NSNib(nibNamed: "BaseTableCell"   , bundle: .main) // TODO: Date table cell
        case .Bool    : nib = NSNib(nibNamed: "BoolTableCell"   , bundle: .main)
        case .Binary  : nib = NSNib(nibNamed: "BaseTableCell"   , bundle: .main) // DEPRECATED, use URLs
        }
        
        tableView.register(nib, forIdentifier: field.name)
        activeColumnId = field.name
    }
    
    func removeColumn() {
        // TODO: Check if column has data, warn user data will be deleted
        print("Remove column...")
        guard let tableView = tableView else { print("No tableView"); return }
        guard let column = tableView.tableColumns.last else { print("No columns"); return }
        let columnId = column.identifier
        guard let field = table.schema.getField(columnId) else { print("No field"); return }
        
        tableView.removeTableColumn(column)
        guard let index = table.schema.fields.index(of: field) else { print("No index"); return }
        table.schema.fields.remove(at: index)
        refresh()
    }
    
    func alignLeft() {
        print("Align left ", activeColumnId)
        guard let column = tableView!.tableColumn(withIdentifier: activeColumnId) else { return }
        guard let field  = table.schema.getField(activeColumnId) else { return }
        guard let cell   = column.dataCell as? NSTextFieldCell else { return }

        field.align = .left
        cell.alignment = .left
        
        refresh()
        print("Left aligned")
    }
    
    func alignCenter() {
        // TODO:
        print("Align center ", activeColumnId)
    }
    
    func alignRight() {
        print("Align right ", activeColumnId)
        guard let column = tableView!.tableColumn(withIdentifier: activeColumnId) else { print("No col"); return }
        guard let field  = table.schema.getField(activeColumnId) else { print("No fld"); return }
        guard let cell   = column.dataCell as? NSTextFieldCell else { print("No cell"); return }

        field.align = .right
        cell.alignment = .right

        refresh()
        print("Right aligned")
    }
    
    func changeDataText() {
        print("Type Text")
        guard let field = table.schema.getField(activeColumnId) else { return }
        field.type = .Text
        field.base = .Text
        // TODO: Align left
        refresh()
    }
    
    func changeDataInt() {
        print("Type Int")
        guard let field = table.schema.getField(activeColumnId) else { return }
        field.type = .Int
        field.base = .Integer
        // TODO: Align right
        refresh()
    }
    
    func changeDataReal() {
        print("Type Real")
        guard let field = table.schema.getField(activeColumnId) else { return }
        field.type = .Real
        field.base = .Real
        // TODO: Align right
        refresh()
    }
    
    func changeDataDate() {
        print("Type Date")
        guard let field = table.schema.getField(activeColumnId) else { return }
        field.type = .Date
        field.base = .Date
        // TODO: Align left
        refresh()
    }
    
    func changeDataTime() {
        print("Type Time")
        guard let field = table.schema.getField(activeColumnId) else { return }
        field.type = .Time
        field.base = .Time
        // TODO: Align left
        refresh()
    }
    
    func changeDataBool() {
        print("Type Bool")
        guard let field = table.schema.getField(activeColumnId) else { return }
        field.type = .Bool
        field.base = .Bool
        // TODO: Make check control
        refresh()
    }
    
    
    // Not used
    func onEditCell(_ sender: NSTextField) {
        guard let cellId = sender.superview?.identifier else { return }
        print("Edited cell \(cellId):", sender.stringValue)
        
        if let row = tableView?.selectedRow, row > -1 {
            // on cell type, if string, number or bool
            table.records[row][cellId] = sender.stringValue
            activeColumnId = cellId
            activeColumn = tableView!.column(withIdentifier: cellId)
            activeRow = tableView!.selectedRow
        }
    }
    
    func onCheckCell(_ sender: NSButton) {
        guard let cellId = sender.superview?.identifier else { return }
        //print("Edited check \(cellId):", sender.state)
        
        if let row = tableView?.selectedRow, row > -1 {
            // on cell type, if string, number or bool
            table.records[row][cellId] = (sender.state == 1)
            //print("Updated record source")
        }
    }

    // Edit cell up on arrow up
    func editCellUp() {
        guard tableView != nil else { return }

        let row = tableView!.selectedRow
        //let col = activeColumn
        let col = tableView!.column(withIdentifier: activeColumnId)
        print("Edit cell up ", row, col, activeColumnId)
        
        guard row > 0, col > -1 else { return }

        tableView!.editColumn(col, row: row-1, with: nil, select: true)
        tableView!.selectRowIndexes([row-1], byExtendingSelection: false)
    }

    // Edit cell down on arrow down
    func editCellDown() {
        guard tableView != nil else { return }

        let row = tableView!.selectedRow
        //let col = activeColumn
        let col = tableView!.column(withIdentifier: activeColumnId)
        print("Edit cell down ", row, col, activeColumnId)
        
        guard row > -1, col > -1 else { return }
        
        if row < tableView!.numberOfRows-1 {
            tableView!.editColumn(col, row: row+1, with: nil, select: true)
            tableView!.selectRowIndexes([row+1], byExtendingSelection: false)
        }
    }

    // Cell editing
    /*
    override func controlTextDidEndEditing(_ obj: Notification) {
        print("Control end editing")
        guard tableView != nil else { return }

        let textField = (obj.object as! NSTextField)
        activeColumnId = (textField.superview?.identifier)!
        activeColumn = tableView!.column(withIdentifier: activeColumnId)
        activeRow = tableView!.selectedRow
        
        if activeRow > -1 {
            // on cell type, if string, number or bool
            table.records[activeRow][activeColumnId] = textField.stringValue
        }

    }
    */
    
    // Column Move
    func tableViewColumnDidMove(_ notification: Notification) {
        // Change field.order
        let oldPos = notification.userInfo?["NSOldColumn"] as! Int
        let newPos = notification.userInfo?["NSNewColumn"] as! Int
        let cellId = table.schema.fields[oldPos].name
        for field in table.schema.fields {
            if field.ordinal >= newPos {
                field.ordinal = field.ordinal + 1
            }
            if field.name == cellId {
                field.ordinal = newPos
            }
        }

        // TODO: Reorder array on ordinal
        
        print("ColumnDidMove ", oldPos, newPos)
    }
    
    // Column Resize
    func tableViewColumnDidResize(_ notification: Notification) {
        // Change field.length and field width
        let column   = notification.userInfo?["NSTableColumn"] as! NSTableColumn
        let columnId = column.identifier
        let oldWidth = notification.userInfo?["NSOldWidth"] as! Int
        let newWidth = column.width
        print("ColumnDidResize ", columnId, oldWidth, newWidth)

        if let field = table.schema.getField(columnId) {
            field.width  = Int(newWidth)
            field.length = Int(field.width / 8) // Aprox ratio between char length and pixel width
            print("New field length ", field.length)
        }
    }
    
    // Column header click
    func tableView(_ tableView: NSTableView, mouseDownInHeaderOf tableColumn: NSTableColumn) {
        activeColumnId = tableColumn.identifier
        print("Column clicked: ", activeColumnId)
    }
    

    
    // Table data source
    func numberOfRows(in tableView: NSTableView) -> Int {
        return table.records.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let item   = table.records[row]
        let cellId = (tableColumn?.identifier)!
        var text   = ""
        
        if item[cellId] != nil {
            text = (item[cellId] as AnyObject).debugDescription!
            //text = item[cellId] as! String
            
            switch item[cellId] {
            case let value as String   : text = value
            case let value as Int      : text = String(value)
            case let value as Double   : text = String(value)
            case let value as NSNumber : text = String(describing: value)
            default: text = "\(item[cellId]!)"
            }
            
        }
        
        if let cell = tableView.make(withIdentifier: cellId, owner: self) as? NSTableCellView {
            if let field = table.schema.getField(cellId) {
                if field.type == .Bool {
                    let boolVal  = item[cellId] as? Bool ?? false
                    let boolCell = cell as! BoolTableCell
                    boolCell.checked = boolVal
                    boolCell.checkbox?.target = self
                    boolCell.checkbox?.action = #selector(TableController.onCheckCell(_:))  // EDITION
                } else {
                    cell.textField?.stringValue = text
                    cell.textField?.target = self
                    //cell.textField?.delegate = self
                    cell.textField?.action = #selector(TableController.onEditCell(_:))  // EDITION
                    switch field.align {
                    case .left   : cell.textField?.alignment = .left
                    case .center : cell.textField?.alignment = .center
                    case .right  : cell.textField?.alignment = .right
                    }
                }
            }
            return cell
        }
        
        return nil
    }
    
}


// END
