//
//  Utils.swift
//  DataText
//
//  Created by Mac Mini on 2/6/17.
//  Copyright © 2017 Armonia. All rights reserved.
//

import Cocoa
import Foundation


extension String {
    
    // To numbers
    
    func toDouble() -> Double {
        var text = self.replacingOccurrences(of: "$", with: "")
        text = text.replacingOccurrences(of: ",", with: "")
        if let value = NumberFormatter().number(from: text)?.doubleValue {
            return value
        }
        return 0.0
    }
    
    func toInteger() -> Int {
        if let value = NumberFormatter().number(from: self)?.intValue {
            return value
        }
        return 0
    }
    
    // Attributed
    
    func strikethrough() -> NSAttributedString {
        let fancy = [NSStrikethroughStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]
        let text  = NSAttributedString(string: self, attributes: fancy)
        return text
    }
    
    func colored(_ color: NSColor) -> NSMutableAttributedString {
        let fancy = [NSForegroundColorAttributeName: color]
        let text  = NSMutableAttributedString(string: self, attributes: fancy)
        return text
    }
    
    // Padding
    
    func padRight(_ n: Int) -> String {
        var text = self
        let size = self.characters.count
        var pad  = n - size
        
        if pad < 0 { pad = size }
        
        for _ in 0..<pad {
            text = text + " "
        }
        
        return text
    }
    
    func padLeft(_ n: Int) -> String {
        var text = self
        let size = self.characters.count
        var pad  = n - size
        
        if pad < 0 { pad = size }
        
        for _ in 0..<pad {
            text = " " + text
        }
        
        return text
    }
    
    // "-".times(5)
    func times(_ n: Int) -> String {
        return String(repeating: self, count: n)
    }
    
    // Substring
    
    func subtext(from pos: Int) -> String {
        guard pos >= 0 else { return "" }
        if pos > self.characters.count { return  "" }
        let first = self.index(self.startIndex, offsetBy: pos)
        let text = self.substring(from: first)
        return text
    }
    
    func subtext(to pos: Int) -> String {
        var end = pos
        if pos > self.characters.count { end = self.characters.count }
        if pos < 0 { end = self.characters.count + pos }
        let last = self.index(self.startIndex, offsetBy: end)
        let text = self.substring(to: last)
        return text
    }
    
    func subtext(from ini: Int, to end: Int) -> String {
        guard ini >= 0 else { return "" }
        var fin = end
        if end < 0 { fin = self.characters.count + end }
        if ini > self.characters.count { return  "" }
        if end > self.characters.count { fin = self.characters.count }
        let first = self.index(self.startIndex, offsetBy: ini)
        let last  = self.index(self.startIndex, offsetBy: fin)
        let range = first ..< last
        let text = self.substring(with: range)
        
        return text
    }
    
    // Regex
    
    func match(_ pattern: String) -> Bool {
        guard self.characters.count > 0 else { return false }
        if let first = self.range(of: pattern, options: .regularExpression) {
            let match = self.substring(with: first)
            return !match.isEmpty
        }
        
        return false
    }
    
    func matchFirst(_ pattern: String) -> String {
        guard self.characters.count > 0 else { return "" }
        if let first = self.range(of: pattern, options: .regularExpression) {
            let match = self.substring(with: first)
            return match
        }
        
        return ""
    }
    
    func matchAll(_ pattern: String) -> [String] {
        var matches = [String]()
        guard self.characters.count > 0 else { return matches }
        let all = NSRange(location: 0, length: self.characters.count)
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let results = regex.matches(in: self, options: [], range: all)
            
            for item in results {
                let first = item.rangeAt(1)
                let range = self.rangeIndex(first)
                let match = self.substring(with: range)
                
                matches.append(match)
            }
        } catch {
            print(error)
        }
        
        return matches
    }
    
    // Painful conversion from a Range to a Range<String.Index>
    func rangeIndex(_ range: NSRange) -> Range<String.Index> {
        let index1 = self.utf16.index(self.utf16.startIndex, offsetBy: range.location, limitedBy: self.utf16.endIndex)
        let index2 = self.utf16.index(index1!, offsetBy: range.length, limitedBy: self.utf16.endIndex)
        let bound1 = String.Index(index1!, within: self)!
        let bound2 = String.Index(index2!, within: self)!
        let result = Range<String.Index>(uncheckedBounds: (bound1, bound2))
        
        return result
    }
    
}


extension Date {
    
    static func fromString(_ text: String) -> Date? {
        // No format? use default
        return fromString(text, format: "yyyy-MM-dd HH:mm:ss")
    }
    
    static func fromString(_ text: String, format: String) -> Date? {
        if !text.isEmpty {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            if let date = formatter.date(from: text) {
                return date
            }
        }
        
        return nil
    }

}


extension Int {

    // Inclusive
    func inRange(_ min: Int, _ max: Int) -> Bool {
        if self >= min && self <= max { return true }
        return false
    }
    
    func plural(_ text: String) -> String {
        let word = text + (self == 1 ? "" : "s")
        return("\(self) \(word)")
    }
    
}

extension Double {
    
    // Accept 123.00 - 1,234.00 and $123.00
    static func fromText(_ text: String) -> Double? {
        var num = text.replacingOccurrences(of: ",", with: "")
        num = num.replacingOccurrences(of: "$", with: "")
        if let value = Double(num) { return value }
        
        return nil
    }
}


// End
