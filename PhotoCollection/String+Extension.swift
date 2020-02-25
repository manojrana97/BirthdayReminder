//
//  StringExtension.swift
//  Hooty
//
//  Created by Sandeep Singh on 07/12/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    func fractionToDobule() -> Double {
        let splitArray = self.components(separatedBy: "/")
        if splitArray.count > 1 {
        let top = Double(splitArray.first ?? "0") ?? 0
        let bottom = Double(splitArray[1] ) ?? 0
            return Double(String(format: "%.2f", top / bottom))!
        }
        return Double(Int(splitArray.first!) ?? 0)
    }
    
    func trimSpace() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var length:Int{
        return self.count
    }
    
    var localized:String {
        return NSLocalizedString(self, comment: self)
    }
    var simplePhoneNumber:String {
        var string = self.replacingOccurrences(of: "-", with: "")
        string = string.replacingOccurrences(of: "(", with: "")
        string = string.replacingOccurrences(of: ")", with: "")
        string = string.replacingOccurrences(of: " ", with: "")
        return string
    }
    
    var toInt:Int? {
        return Int.init(self)
    }
    
    var toFloat:Float? {
        return Float.init(self)
    }
    
    var toDouble:Double? {
        return Double.init(self)
    }
    var html2AttributedString : NSAttributedString? {
        do {
            return try NSAttributedString(data: Data(utf8),
                                          options: [.documentType: NSAttributedString.DocumentType.html,
                                                    .characterEncoding: String.Encoding.utf8.rawValue],
                                          documentAttributes: nil)
        } catch {
        
            return  nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
    
    func size(OfFont font: UIFont) -> CGSize {
        return (self as NSString).size(withAttributes: [NSAttributedString.Key.font: font])
    }
}


extension Int {
    
    var toString:String{
        return String.init(describing: self)
    }
}


extension Double {
    
    var toString:String{
        return String.init(describing: self)
    }
}


extension Float{
    
    var toString:String{
        return String.init(describing: self)
    }
}

extension String {
    var floatValue: Float {
        return (self as NSString).floatValue
    }
}

