//
//  UIFont+Extension.swift
//  Partya
//
//  Created by Zimble on 8/18/21.
//

import Foundation
import UIKit


enum FontName: Int {
    case appFontRegular = 1
    case appFontMedium = 2
    case appFontBold = 3
    case appFontBlack = 4

    var getFontName: String {
        if (self == FontName.appFontRegular) { return "MavenPro-Regular" }
        if (self == FontName.appFontMedium) { return "MavenPro-Medium" }
        if (self == FontName.appFontBold) { return "MavenPro-Bold" }
        if (self == FontName.appFontBlack) { return "MavenPro-Black" }

        return "MavenPro-Regular"
    }
}

extension UIFont {
    
    class func logAllFont() -> Void {
        let familyNames = UIFont.familyNames
        for family in familyNames {
            print("Family name " + family)
            let fontNames = UIFont.fontNames(forFamilyName: family)
            for font in fontNames {
                print("    Font name: " + font)
            }
        }
    }
    
    class func appFontRegular(size: CGFloat, isFixedSize: Bool = false) -> UIFont
    {
        return UIFont.fontWithName(name: FontName.appFontRegular, size: size, isFixedSize: isFixedSize)
    }
    
    class func appFontBold(size: CGFloat, isFixedSize: Bool = false) -> UIFont
    {
        return UIFont.fontWithName(name: FontName.appFontBold, size: size, isFixedSize: isFixedSize)
    }
    
    class func appFontBlack(size: CGFloat, isFixedSize: Bool = false) -> UIFont
    {
        return UIFont.fontWithName(name: FontName.appFontBlack, size: size, isFixedSize: isFixedSize)
    }
    
    class func appFontMedium(size: CGFloat, isFixedSize: Bool = false) -> UIFont
    {
        return UIFont.fontWithName(name: FontName.appFontMedium, size: size, isFixedSize: isFixedSize)
    }
    
    class func fontWithName(name: FontName, size: CGFloat, isFixedSize: Bool = false) -> UIFont
    {
        var getFontSize: CGFloat = size
        if (!isFixedSize) {
            getFontSize = getFontSize.proportionalFontSize()
        }
        return UIFont(name: name.getFontName, size: getFontSize) ?? UIFont.systemFont(ofSize: getFontSize)
    }
}
