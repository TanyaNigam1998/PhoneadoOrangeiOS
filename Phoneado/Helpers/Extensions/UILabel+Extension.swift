//
//  UILabel+Extension.swift
//  Quicklyn
//
//  Created by Zimble on 12/2/21.
//

import Foundation
import UIKit

class CustomLabel: UILabel {
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func applyAttributesForReadMore(fontsize: CGFloat) {
        guard let txt = self.text else { return }
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 1.5
        
        let attrib: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font: UIFont.appFontRegular(size: fontsize), NSAttributedString.Key.foregroundColor: UIColor.black ]
        let attribStr = NSMutableAttributedString.init(string: txt, attributes: attrib)
        attribStr.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: NSRange(location: 0, length: txt.count))
        attribStr.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.appFontRegular(size: fontsize)], range: (txt as NSString).range(of: "Read less"))
        attribStr.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.appFontRegular(size: fontsize)], range: (txt as NSString).range(of: "Read more"))
        self.attributedText = attribStr
    }
}

class CustomLabelRegular: CustomLabel {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.doSetUpFont()
    }
    
    private func doSetUpFont() {
        guard let font = self.font else { return }
        self.font = UIFont.appFontRegular(size: font.pointSize)
    }
    
}

//class CustomLabelLight: CustomLabel {
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        self.doSetUpFont()
//    }
//
//    private func doSetUpFont() {
//        guard let font = self.font else { return }
//        self.font = UIFont.appFontLight(size: font.pointSize)
//    }
//
//}

class CustomLabelMedium: CustomLabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.doSetUpFont()
    }
    
    private func doSetUpFont() {
        guard let font = self.font else { return }
        self.font = UIFont.appFontMedium(size: font.pointSize)
    }
    
}

class CustomLabelBold: CustomLabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.doSetUpFont()
    }
    
    private func doSetUpFont() {
        guard let font = self.font else { return }
        self.font = UIFont.appFontBold(size: font.pointSize)
    }
    
}

class CustomLabelBlack: CustomLabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.doSetUpFont()
    }
    
    private func doSetUpFont() {
        guard let font = self.font else { return }
        self.font = UIFont.appFontBlack(size: font.pointSize)
    }
    
}

extension UILabel{

  func animation(typing value:String,duration: Double){
    let characters = value.map { $0 }
    var index = 0
    Timer.scheduledTimer(withTimeInterval: duration, repeats: true, block: { [weak self] timer in
        if index < value.count {
            let char = characters[index]
            self?.text! += "\(char)"
            index += 1
        } else {
            timer.invalidate()
        }
    })
  }


  func textWithAnimation(text:String,duration:CFTimeInterval){
    fadeTransition(duration)
    self.text = text
  }

  //followed from @Chris and @winnie-ru
  func fadeTransition(_ duration:CFTimeInterval) {
    let animation = CATransition()
    animation.timingFunction = CAMediaTimingFunction(name:
        CAMediaTimingFunctionName.easeInEaseOut)
    animation.type = CATransitionType.fade
    animation.duration = duration
    layer.add(animation, forKey: CATransitionType.fade.rawValue)
  }
}

extension UITapGestureRecognizer {
    
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
}
