//
//  DataTable.swift
//  DataText
//
//  Created by Mac Mini on 2/6/17.
//  Copyright © 2017 Armonia. All rights reserved.
//

import Foundation

class DataTable {
    
    var url: URL?
    var name    = ""
    var schema  = DataSchema()
    var records = DataResults()
    
    var text: String {
        get {
            let text = rowsToText()
            print("Get Text: \n\(text)")
            return text
        }
        set {
            // Load table records from text
            print("Set Text: \n\(newValue)")
            textToRows(newValue)
        }
    }
    
    // From text to records
    
    func textToRows(_ text: String) {
        //print("Parsing...")
        if text.isEmpty { return }
        
        let lines = text.components(separatedBy: "\n")
        let count = lines.count
        var head  = ""
        var dash  = ""
        
        var useFields = false
        
        if count > 0 { head = lines[0] } // First row is head
        if count > 1 { dash = lines[1] } // Second row is dashes
        if !dash.isEmpty && dash.characters.count > 3 && dash.hasPrefix("[ --") {
            useFields = true
        }
        
        if useFields {
            getFields(head)               // if has header in line 0, use fields from header
            getRecords(lines, start: 2)   // data starts in line 2
        } else {
            setFields(head)               // if no header, assign column1, column2 ... columnN
            getRecords(lines, start: 0)   // data starts in line 0
        }
        
        //print("Fields: ", schema.fields.map{ $0.name })
        //print("Records: ", records)
    }
    
    func getFields(_ head: String) {
        let parts = head.subtext(from: 1, to: -1).components(separatedBy: "|")
        //print(parts)
        
        for (index, item) in parts.enumerated() {
            let field = TableField()
            if item.hasPrefix("  ") {
                field.align = CellAlign.right
            }
            field.ordinal  = index
            field.length   = item.characters.count - 2 // minus two padding spaces
            field.name     = item.trimmingCharacters(in: .whitespaces)
            field.width    = field.length * 8 // pixels for column width
            
            schema.fields.append(field)
        }
    }
    
    func setFields(_ head: String) {
        let parts = head.components(separatedBy: "|")

        for index in 0..<parts.count {
            let field = TableField()
            field.ordinal = index
            field.name    = "Column\(index+1)"
            field.length  = 40
            field.width   = 200   // Used in table columns

            schema.fields.append(field)
        }
    }
    
    func getRecords(_ data: [String], start: Int) {
        for (index, line) in data.enumerated() {
            if index < start { continue }
            if line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { continue }

            var row = [String: Any]()
            let cells = line.subtext(from: 1, to: -1).components(separatedBy: "|")
            
            for (col, cell) in cells.enumerated() {
                let text = cell.trimmingCharacters(in: .whitespaces)
                
                if index == start { // Sample types
                    let low = text.lowercased()
                    if low == "x" || low == "true" || low == "false" || low == "yes" || low == "no" {
                        schema.fields[col].base = .Bool
                        schema.fields[col].type = .Bool
                    } else if Double.fromText(text) != nil && text.contains(".") {
                        let dot = text.characters.index(of: ".")
                        let dec = text.distance(from: dot!, to: text.endIndex) - 1
                        schema.fields[col].base = .Real
                        schema.fields[col].type = .Real
                        schema.fields[col].decimals = dec
                        //print("Decimals: ", dec)
                    } else if Int(text) != nil {
                        schema.fields[col].base = .Integer
                        schema.fields[col].type = .Int
                    } else if Date.fromString(text, format: "yyyy-MM-dd") != nil {
                        schema.fields[col].base = .Date
                        schema.fields[col].type = .Date
                    } else if Date.fromString(text, format: "yyyy-MM-dd HH:mm:ss") != nil {
                        schema.fields[col].base = .Date
                        schema.fields[col].type = .Time
                    }
                }
                
                let name = schema.fields[col].name
                let type = schema.fields[col].type

                switch type {
                case .Text : row[name] = text
                case .Int  : row[name] = text // Int(text) ?? text
                case .Real : row[name] = text // Double(text) ?? text
                case .Date : row[name] = text
                case .Time : row[name] = text
                case .Bool : row[name] = (text == "x" || text == "true" || text == "yes")
                default    : row[name] = text
                }

                /*
                 switch type {
                 case .Text: row[name] = text
                 case .Int:  row[name] = Int(text) ?? text
                 case .Real: row[name] = Double(text) ?? text
                 case .Date: row[name] = Date.fromString(text, format: "yyyy-MM-dd") ?? text
                 case .Time: row[name] = Date.fromString(text, format: "yyyy-MM-dd HH:mm:ss") ?? text
                 case .Bool: row[name] = (text == "x" || text == "true" || text == "yes")
                 default   : row[name] = text
                 }
                 */
            }
            records.append(row)
        }
    }

    // From records to text

    func rowsToText() -> String{
        var text = ""
        
        // TODO: Calc max width by fields on max row cell
        
        // Head from fields
        var head = "["
        var dash = "["
        
        for (index, field) in schema.fields.enumerated() {
            var name = field.name
            let line = "-".times(field.length)
            
            if field.align == .right { name = name.padLeft(field.length) }
            else { name = name.padRight(field.length) }
            
            head += " " + name + " "
            dash += " " + line + " "
            
            if index < schema.fields.count - 1 {
                head += "|"
                dash += "|"
            }
        }
        
        head += "]\n"
        dash += "]\n"
        
        // Body from records
        var body = ""
        
        for record in records {
            var row = "["
            
            for (index, field) in schema.fields.enumerated() {
                // Convert by type, switch?
                var cellText = String(describing: record[field.name]!)
                
                if field.align == .right { cellText = cellText.padLeft(field.length) }
                else { cellText = cellText.padRight(field.length) }

                row += " " + cellText + " "
                
                if index < schema.fields.count - 1 {
                    row += "|"
                }
            }
            
            body += row + "]\n"
        }
        
        text += head
        text += dash
        text += body
        
        return text
    }
}
