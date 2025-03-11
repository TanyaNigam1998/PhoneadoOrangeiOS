//
//  String+Extension.swift
//  Quicklyn
//
//  Created by Zimble on 12/3/21.
//

import Foundation
import UIKit

extension String {
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    func isValidPassword() -> Bool {
        let passwordRegex = "^(?=.*\\d)(?=.*[a-z])(?=.*[A-Z])[0-9a-zA-Z!@#$%^&*()\\-_=+{}|?>.<,:;~`’]{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: self)
    }
    
    func verifyUrl () -> Bool {
        if let url = URL(string: self) {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }
    
    func decodeString() -> String? {
        let trimmedString = self.trimmingCharacters(in: .whitespacesAndNewlines)
        if let stringData = trimmedString.data(using: .utf8) {
            let messageString = String(data: stringData, encoding: .nonLossyASCII)
            return messageString
        }

        return nil
    }
    
    func deletePrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
    
    func isContainsOnlyNumbers() -> Bool {
        return self.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
    
    func isValidUsername() -> Bool
    {
        let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_.")
        if self.rangeOfCharacter(from: characterset.inverted) != nil {
            return false
        }
        return true
    }
    
    var maskEmail: String {
            let email = self
            let components = email.components(separatedBy: "@")
            var maskEmail = ""
            if let first = components.first {
                maskEmail = String(first.enumerated().map { index, char in
                    return [0, 1, first.count - 1, first.count - 2].contains(index) ?
    char : "*"
                })
            }
            if let last = components.last {
                maskEmail = maskEmail + "@" + last
            }
            return maskEmail
        }


      var maskPhoneNumber: String {
        return String(self.enumerated().map { index, char in
            return [0, 3, self.count - 1, self.count - 2].contains(index) ?
        char : "*"
        })
    }
    
    var maskCardNumber: String {
      return String(self.enumerated().map { index, char in
          return [0,1,2,3,4,5,6, self.count - 1, self.count - 2].contains(index) ?
      char : "*"
      })
  }
    
    var getUrl: URL? {
        if (self.lowercased() as NSString).hasPrefix("http://") || (self.lowercased() as NSString).hasPrefix("https://") {
            if let strurl = (self as NSString).addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) {
                return URL(string: strurl)
            }
            return nil
        }
        else {
            return URL(fileURLWithPath: self)
        }
    }
    
    var trailingSpacesTrimmed: String {
        var newString = self

        while newString.last?.isWhitespace == true {
            newString = String(newString.dropLast())
        }
        
        while newString.first?.isWhitespace == true {
            newString = String(newString.dropFirst())
        }

        return newString
    }
    
    func allIndexes(of subString: String, caseSensitive: Bool = true) -> [Int] {
        let subString = caseSensitive ? subString : subString.lowercased()
        let mainString = caseSensitive ? self : self.lowercased()
        var indices = [Int]()
        var searchStartIndex = mainString.startIndex
        while searchStartIndex < mainString.endIndex,
            let range = mainString.range(of: subString, range: searchStartIndex..<mainString.endIndex),
            !range.isEmpty
        {
            let index = distance(from: mainString.startIndex, to: range.lowerBound)
            indices.append(index)
            searchStartIndex = range.upperBound
        }

        return indices
    }
    
    func getIndexes(of subString: String, caseSensitive: Bool = true) -> [Int] {
        let subString = caseSensitive ? subString : subString.lowercased()
        let mainString = caseSensitive ? self : self.lowercased()
        var indices = [Int]()
        var searchStartIndex = mainString.startIndex
        while searchStartIndex < mainString.endIndex,
            let range = mainString.range(of: subString, range: searchStartIndex..<mainString.endIndex),
            !range.isEmpty
        {
            let index = distance(from: mainString.startIndex, to: range.lowerBound)
            indices.append(index)
            searchStartIndex = range.upperBound
        }

        return indices
    }
    
    public func separate(withChar char : String) -> [String]{
        var word : String = ""
        var words : [String] = [String]()
        for chararacter in self {
            if String(chararacter) == char && word != ""
            {
                words.append(word)
                word = char
            }
            else
            {
                word += String(chararacter)
            }
        }
        words.append(word)
        return words
    }
    
    func removingWhitespaces() -> String {
            return components(separatedBy: .whitespaces).joined()
        }
    
    subscript(_ range: CountableRange<Int>) -> String {
            let start = index(startIndex, offsetBy: max(0, range.lowerBound))
            let end = index(start, offsetBy: min(self.count - range.lowerBound,
                                                 range.upperBound - range.lowerBound))
            return String(self[start..<end])
        }

        subscript(_ range: CountablePartialRangeFrom<Int>) -> String {
            let start = index(startIndex, offsetBy: max(0, range.lowerBound))
             return String(self[start...])
        }
    
    var containsEmoji: Bool {
        for scalar in unicodeScalars {
            switch scalar.value {
            case 0x1F600...0x1F64F, // Emoticons
                 0x1F300...0x1F5FF, // Misc Symbols and Pictographs
                 0x1F680...0x1F6FF, // Transport and Map
                 0x2600...0x26FF,   // Misc symbols
                 0x2700...0x27BF,   // Dingbats
                 0xFE00...0xFE0F,   // Variation Selectors
                 0x1F900...0x1F9FF, // Supplemental Symbols and Pictographs
                 0x1F1E6...0x1F1FF: // Flags
                return true
            default:
                continue
            }
        }
        return false
    }
    
    func countEmojiCharacter() -> Int {

            func isEmoji(s:NSString) -> Bool {

                let high:Int = Int(s.character(at: 0))
                if 0xD800 <= high && high <= 0xDBFF {
                    let low:Int = Int(s.character(at: 1))
                    let codepoint: Int = ((high - 0xD800) * 0x400) + (low - 0xDC00) + 0x10000
                    return (0x1D000 <= codepoint && codepoint <= 0x1F9FF)
                }
                else {
                    return (0x2100 <= high && high <= 0x27BF)
                }
            }

            let nsString = self as NSString
            var length = 0

        nsString.enumerateSubstrings(in: NSMakeRange(0, nsString.length), options: NSString.EnumerationOptions.byComposedCharacterSequences) { (subString, substringRange, enclosingRange, stop) -> Void in

            if isEmoji(s: subString! as NSString) {
                    length += 1
                }
            }

            return length
        }
    
}

extension Int {
    static func getInt(from string: String) -> Int? {
        return Int(string.components(separatedBy: CharacterSet.decimalDigits.inverted).joined())
    }
}
