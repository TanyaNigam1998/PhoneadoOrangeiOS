//
//  UIColor+Extension.swift
//  Quicklyn
//
//  Created by Zimble on 12/2/21.
//

import Foundation
import UIKit

extension UIColor {
    
    static private func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    static let appThemeColor = #colorLiteral(red: 0.92437011, green: 0.3929250836, blue: 0, alpha: 0.9)
    static let gradientColor1 = #colorLiteral(red: 0.9333333333, green: 0.2274509804, blue: 0.01960784314, alpha: 0.9)
    static let gradientColor2 = #colorLiteral(red: 0.9921568627, green: 0.6666666667, blue: 0.1607843137, alpha: 0.92)
//    static let gradientColor3 = UIColor.init(red: 233.0/255.0, green: 248.0/255.0, blue: 254.0/255.0, alpha: 1)
    static let gradientColor4 = UIColor.hexStringToUIColor(hex: "#EA7222")
    
    /*
     Type: Linear
     Angle: 90˚
     Opacity: 100%

     Color Stop 1
     Color: RGB(213, 237, 255)
     Position: 0%

     Color Stop 2
     Color: RGB(244, 244, 252)
     Position: 59%

     Color Stop 3
     Color: RGB(233, 248, 254)
     Position: 100%
     */
    
    static let shadowColor = UIColor.hexStringToUIColor(hex: "#5c0b46")
    static let shadyColor = UIColor.hexStringToUIColor(hex: "#9698A4")
    static let pagerColor = UIColor.hexStringToUIColor(hex: "#56C4C7")
    static let defaultButtonColor = UIColor.hexStringToUIColor(hex: "#FFD052")
    static let alertButtonColor = UIColor(red:0.05, green:0.26, blue:0.93, alpha:1)
    static let borderClr = UIColor(red:151.0/255.0, green:151.0/255.0, blue:151.0/255.0, alpha:0.08)
    static let greyTextColor = UIColor.hexStringToUIColor(hex: "#777777")
    static let lightGreyTextColor = UIColor.init(red: 238.0/255.0, green: 238.0/255.0, blue: 238.0/255.0, alpha: 1.0)
    static let lightBorderColor = UIColor.hexStringToUIColor(hex: "#EEEEEE")
    static let appDarkGreenColor = UIColor.init(red: 0.0/255.0, green: 113.0/255.0, blue: 118.0/255.0, alpha: 0.45)
    static let appLightGreenColor = UIColor.init(red: 0.0/255.0, green: 113.0/255.0, blue: 118.0/255.0, alpha: 0.12)
    static let appOrangeColor = UIColor.init(red: 241.0/255.0, green: 140.0/255.0, blue: 52.0/255.0, alpha: 1.0)
    static let lightOrangeColor = UIColor.init(red: 255.0/255.0, green: 134.0/255.0, blue: 4.0/255.0, alpha: 0.10)
    
    static let homeSearchViewBorderColor = UIColor.init(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.03)
    static let homeSelectAllViewBackgroundColor = UIColor.init(red: 216.0/255.0, green: 216.0/255.0, blue: 216.0/255.0, alpha: 1.0)
    static let messagesTVHeaderLblColor = UIColor.init(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.5)
    
}
