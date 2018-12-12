//
//  ExtensionFile.swift
//  ProjectTemplate
//
//  Created by Ankit Goyal on 15/03/2018.
//  Copyright © 2018 Applify Tech Pvt Ltd. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
extension UIView {
   
    class func loadFromNibNamed(_ nibNamed: String, bundle : Bundle? = nil) -> UIView? {
        let view = UINib(
            nibName: nibNamed,
            bundle: bundle
            ).instantiate(withOwner: nil, options: nil)[0] as? UIView
        view?.frame = CGRect.init(x: 0, y: 0, width: KScreenWidth, height: KScreenHeight)
        return view
    }
}



//Extensions
extension UIColor{
    class func rbg(r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
        let color = UIColor.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
        return color
    }
    public convenience init(hexString: String) {
        let hexString = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) as String
        let scanner = Scanner(string: hexString)
        
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        self.init(red:red, green:green, blue:blue, alpha:1)
    }
}
extension String {
    func rangeFromNSRange(string:String,range : Range<String.Index>) -> NSRange? {
        guard let range = self.range(of: string, options: .caseInsensitive, range: range, locale: .current) else {
            return nil
            
        }
        
        return NSRange(range, in: self)
    }
    func nsRange(from range: Range<String.Index>) -> NSRange {
        let from = range.lowerBound.samePosition(in: utf16)!
        let to = range.upperBound.samePosition(in: utf16)!
        
        return NSRange(location: utf16.distance(from: utf16.startIndex, to: from),
                       length: utf16.distance(from: from, to: to))
    }
}
