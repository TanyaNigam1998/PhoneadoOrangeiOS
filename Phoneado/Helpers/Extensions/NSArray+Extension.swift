//
//  NSArray+Extension.swift
//  Quicklyn
//
//  Created by Zimble on 12/6/21.
//

import Foundation

extension NSArray {
    
    func arrayByReplacingNullsWithBlanks () -> NSMutableArray
    {
        let arrReplaced : NSMutableArray = self.mutableCopy() as! NSMutableArray
        let null : AnyObject = NSNull()
        let blank : NSString = ""
        for idx in 0 ..< arrReplaced.count {
            let object : AnyObject = arrReplaced.object(at: idx) as AnyObject
            if object.isEqual(null) {
                arrReplaced.setValue(blank, forKey: object.key!!)
            } else if let object = object as? NSDictionary {
                arrReplaced.replaceObject(at: idx, with: object.dictionaryByReplacingNullsWithBlanks())
            }else if let object = object as? NSArray {
                arrReplaced.replaceObject(at: idx, with: object.arrayByReplacingNullsWithBlanks())
            }
        }
        return arrReplaced
    }
    
}
