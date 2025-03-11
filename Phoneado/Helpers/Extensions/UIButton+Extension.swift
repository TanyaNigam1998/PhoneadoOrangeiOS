//
//  UIButton+Extension.swift
//  Quicklyn
//
//  Created by Zimble on 12/2/21.
//

import Foundation
import UIKit

extension UIView {
    func fetchGradientLayer() -> CAGradientLayer {
        self.layer.sublayers?.forEach({ (lay) in
            if (lay is CAGradientLayer) {
                lay.removeFromSuperlayer()
            }
        })
        let l = CAGradientLayer()
        l.frame = self.bounds
        l.colors = [UIColor.gradientColor1.cgColor, UIColor.gradientColor2.cgColor]
        l.startPoint = CGPoint(x: 0, y: 1)
        l.endPoint = CGPoint(x: 1, y: 1)
//        if let btn = self as? CustomButton, !btn.isCornnerRadiusRequire {
//            l.cornerRadius = 0.0
//        } else {
//            l.cornerRadius = (self.layer.cornerRadius != 0.0) ? self.layer.cornerRadius : 8.0
//        }
        layer.insertSublayer(l, at: 0)
        return l
    }
    
    func fetchGradientLayer1() -> CAGradientLayer {
        self.layer.sublayers?.forEach({ (lay) in
            if (lay is CAGradientLayer) {
                lay.removeFromSuperlayer()
            }
        })
        let l = CAGradientLayer()
        l.frame = self.bounds
        l.colors = [UIColor.gradientColor1.cgColor, UIColor.gradientColor2.cgColor]
        l.startPoint = CGPoint(x: 0, y: 0.5)
        l.endPoint = CGPoint(x: 1, y: 0.5)
        l.cornerRadius = 0.0
        
        layer.insertSublayer(l, at: 0)
        return l
    }
    
    func applyGradientColor(_ colors: [UIColor] = [UIColor.gradientColor1, UIColor.gradientColor2]) {
        let gradientLayer = self.fetchGradientLayer()
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.frame = self.bounds
    }
    
    func applyGradientColor1(_ colors: [UIColor] = [UIColor.gradientColor1, UIColor.gradientColor2]) {
        let gradientLayer = self.fetchGradientLayer1()
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.frame = self.bounds
    }
}


class CustomButton: UIButton {
    var isCornnerRadiusRequire: Bool = true
    var isGradiantLayerEnable: Bool = false {
        didSet {
            self.layoutSubviews()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if (isGradiantLayerEnable) {
            self.backgroundColor = UIColor.clear
            let gradientLayer = self.fetchGradientLayer()
            gradientLayer.frame = bounds
        } else {
            self.layer.sublayers?.forEach({ (lay) in
                if let ly = lay as? CAGradientLayer {
                    ly.removeFromSuperlayer()
                }
            })
        }
    }
}

class CustomButtonRegular: CustomButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.doSetUpFont()
    }
    
    private func doSetUpFont() {
        guard let label = self.titleLabel, let font = label.font else { return }
        label.font = UIFont.appFontMedium(size: font.pointSize)
    }
    
}

//class CustomButtonLight: CustomButton {
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        self.doSetUpFont()
//    }
//
//    private func doSetUpFont() {
//        guard let label = self.titleLabel, let font = label.font else { return }
//        label.font = UIFont.appFontLight(size: font.pointSize)
//    }
//
//}

class CustomButtonBold: CustomButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.doSetUpFont()
    }
    
    private func doSetUpFont() {
        guard let label = self.titleLabel, let font = label.font else { return }
        label.font = UIFont.appFontBold(size: font.pointSize)
    }
}
