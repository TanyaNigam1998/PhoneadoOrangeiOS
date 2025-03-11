//
//  Double+Extension.swift
//  Quicklyn
//
//  Created by Zimble on 12/2/21.
//

import Foundation
import UIKit

extension CGFloat {
    
    func proportionalFontSize() -> CGFloat {
        
        return floor((self * Device.SCREEN_WIDTH) / 375.0)
    }
    
}

extension Double
{
    func getTime() -> String
    {
        let date = Date(timeIntervalSince1970: self)
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.short //Set time style
        dateFormatter.dateStyle = DateFormatter.Style.none //Set date style
        dateFormatter.timeZone = .current
        let localDate = dateFormatter.string(from: date)
        return localDate
    }
}
