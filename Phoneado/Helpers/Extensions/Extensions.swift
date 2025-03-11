//
//  Extensions.swift
//  Phoneado
//
//  Created by Zimble on 3/23/22.
//

import Foundation
import UIKit
import ContactsUI
import CommonCrypto
//MARK: - Attributed String Extension
extension NSMutableAttributedString {
    func setColorForText(textForAttribute: String, withColor color: UIColor) {
        let range: NSRange = self.mutableString.range(of: textForAttribute, options: .caseInsensitive)
        // Swift 4.2 and above
        self.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
    }
}
extension UIViewController {
    func showToast(message : String, font: UIFont) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}
extension Dictionary {
    mutating func merge(dict: [Key: Value]){
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
}
extension Array where Element: Equatable{
    mutating func remove (element: Element) {
        if let i = self.firstIndex(of: element) {
            self.remove(at: i)
        }
    }
}
extension UIImage {
    public func sha256() -> String{
        if let imageData = cgImage?.dataProvider?.data as? Data {
            return hexStringFromData(input: digest(input: imageData as NSData))
        }
        return ""
    }
    private func digest(input : NSData) -> NSData {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hash = [UInt8](repeating: 0, count: digestLength)
        CC_SHA256(input.bytes, UInt32(input.length), &hash)
        return NSData(bytes: hash, length: digestLength)
    }
    private  func hexStringFromData(input: NSData) -> String {
        var bytes = [UInt8](repeating: 0, count: input.length)
        input.getBytes(&bytes, length: input.length)
        
        var hexString = ""
        for byte in bytes {
            hexString += String(format:"%02x", UInt8(byte))
        }
        return hexString
    }
}


struct Checksum {
    private init() {}

    static func hash(data: Data, using algorithm: HashAlgorithm) -> String {
        /// Creates an array of unsigned 8 bit integers that contains zeros equal in amount to the digest length
        var digest = [UInt8](repeating: 0, count: algorithm.digestLength())

        /// Call corresponding digest calculation
        data.withUnsafeBytes {
            algorithm.digestCalculation(data: $0.baseAddress, len: UInt32(data.count), digestArray: &digest)
        }

        var hashString = ""
        /// Unpack each byte in the digest array and add them to the hashString
        for byte in digest {
            hashString += String(format:"%02x", UInt8(byte))
        }

        return hashString
    }
    
    enum HashAlgorithm {
        case md5
        case sha256

        func digestLength() -> Int {
            switch self {
            case .md5:
                return Int(CC_MD5_DIGEST_LENGTH)
            case .sha256:
                return Int(CC_SHA256_DIGEST_LENGTH)
            }
        }

        /// CC_[HashAlgorithm] performs a digest calculation and places the result in the caller-supplied buffer for digest
        /// Calls the given closure with a pointer to the underlying unsafe bytes of the data's contiguous storage.
        func digestCalculation(data: UnsafeRawPointer!, len: UInt32, digestArray: UnsafeMutablePointer<UInt8>!) {
            switch self {
            case .md5:
                CC_MD5(data, len, digestArray)
            case .sha256:
                CC_SHA256(data, len, digestArray)
            }
        }
    }
}
extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the amount of nanoseconds from another date
    func nanoseconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.nanosecond], from: date, to: self).nanosecond ?? 0
    }
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date))y"   }
        if months(from: date)  > 0 { return "\(months(from: date))M"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
        if days(from: date)    > 0 { return "\(days(from: date))d"    }
        if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
        if nanoseconds(from: date) > 0 { return "1s" }
        return ""
    }
    func stringFromDate(format: String) -> String? {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = format
        return dateformatter.string(from: self)
    }
    func dateInMiliseconds() -> Int {
        
        let since1970 = self.timeIntervalSince1970
        return Int(since1970 * 1000)
    }
    func dateInseconds() -> Int {
        
        let since1970 = self.timeIntervalSince1970
        return Int(since1970)
    }
    func toUTCDate() -> Date {
        let timezone = TimeZone.current
        let seconds = -TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
}
extension Int{
    func dateFromTimeStamp () ->Date{
        return Date(timeIntervalSince1970: (Double(self)))
    }
    func dateFromTimeStampSeconds () ->Date{
        return Date(timeIntervalSince1970: TimeInterval((self )))
    }
}

extension Double{
    func dateFromTimeStamp () ->Date{
        return Date(timeIntervalSince1970: (Double(self)))
    }
    func dateFromTimeStampSeconds () ->Date{
        return Date(timeIntervalSince1970: TimeInterval((self )))
    }
}
