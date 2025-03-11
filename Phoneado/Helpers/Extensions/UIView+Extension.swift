//
//  UIView+Extension.swift
//  Quicklyn
//
//  Created by Zimble on 12/2/21.
//

import Foundation
import UIKit

extension UIView {
    var width: CGFloat {
        get { return self.frame.size.width }
        set { self.frame.size.width = newValue }
    }
    
    var height: CGFloat {
        get { return self.frame.size.height }
        set { self.frame.size.height = newValue }
    }
    
    var xPos: CGFloat {
        get { return self.frame.origin.x }
        set { self.frame.origin.x = newValue }
    }
    
    var yPos: CGFloat {
        get { return self.frame.origin.y }
        set { self.frame.origin.y = newValue }
    }
    
    var size: CGSize {
        get { return self.frame.size }
        set { self.frame.size = newValue }
    }

    func addShadowBackGround() {
//        self.layer.cornerRadius = 8
        self.backgroundColor = UIColor.white
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.09).cgColor
        self.layer.shadowOpacity = 1
        self.accessibilityLabel = "shadowLayer"
        self.tag = 9834
        self.layer.shadowRadius = 8
    }
    
    func addShadowWithCorner(shadowColor color:UIColor = UIColor.shadowColor,
                             shadowOffset offset:CGSize = CGSize(width: 0, height: 1.5),
                             shadowOpacity opacity : Float = 0.6,
                             shadowRadius radius : CGFloat = 3.0,
                             cornerRadius :CGFloat = 3.0) {
        self.clipsToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = offset
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
        self.layer.cornerRadius = cornerRadius
    }
    
    func addDefaultShadow(withColor color: UIColor = UIColor.gray, shadowOffset offset:CGSize = CGSize(width: 1, height: 1), opacity op: Float = 0.5)
    {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = offset
        self.layer.shadowOpacity = op
        self.layer.masksToBounds = false
        self.clipsToBounds = false
    }
    
    func applyCorner(_ radius: CGFloat? = nil)
    {
        self.layoutIfNeeded()
        if let validradius = radius {
            self.layer.cornerRadius = validradius
        } else {
            let newradius = min(self.height, self.width)
            self.applyCorner(newradius / 2)
        }
        self.layer.masksToBounds = (self is UIImageView) ? true : self.layer.masksToBounds
    }
    
    func applyBorder(_ color:UIColor, width:CGFloat) {
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    class func loadFromNib() -> Self {
        return fromNib()
    }
    
    private class func fromNib<T>() -> T {
        let view = UINib(nibName: String(describing: self), bundle: nil).instantiate(withOwner: nil, options: nil).first as! T
        return view
    }
    
    //MARK:- constraint
    var heightConstaint: NSLayoutConstraint? {
        get {
            return self.constraints.first(where: { $0.firstAttribute == .height && $0.relation == .equal })
        }
    }
    
    var widthConstaint: NSLayoutConstraint? {
        get {
            return self.constraints.first(where: { $0.firstAttribute == .width && $0.relation == .equal })
        }
    }
    
    func applyDropShadowShadow() {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        self.layer.shadowOpacity = 0.20
        self.layer.shadowRadius = 5.0
    }
    
    func removeDropShadow() {
        self.layer.masksToBounds = true
        self.layer.shadowColor = UIColor.clear.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowOpacity = 0
        self.layer.shadowRadius = 0.0
    }
}

//MARK:-  ReusableView
protocol NibLoadableView: AnyObject {
    static var nibName: UINib { get }
    static var className: String { get }
}

extension NibLoadableView where Self: UIView {
    static var nibName: UINib {
        return UINib.init(nibName: String(describing: self), bundle: nil)
    }
    
    static var className: String {
        return String(describing: self)
    }
}

extension UIView: NibLoadableView {
    
}

extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
            if #available(iOS 11.0, *) {
                clipsToBounds = true
                layer.cornerRadius = radius
                layer.maskedCorners = CACornerMask(rawValue: corners.rawValue)
            } else {
                let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
                let mask = CAShapeLayer()
                mask.path = path.cgPath
                layer.mask = mask
            }
    }
    
    
}

@IBDesignable class UIRoundedView: UIView {
    
    @IBInspectable var isRoundedCorners: Bool = false {
        didSet { setNeedsLayout() }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if isRoundedCorners {
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = UIBezierPath(ovalIn:
                CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.width, height: bounds.height
            )).cgPath
            layer.mask = shapeLayer
        }
        else {
            layer.mask = nil
        }
        
    }
}

@IBDesignable
class StylishView: UIView
{
    let gradientLayer = CAGradientLayer()
    
    @IBInspectable
    var topGradientColor: UIColor? {
        didSet {
            setGradient(topGradientColor: topGradientColor, bottomGradientColor: bottomGradientColor)
        }
    }
    
    @IBInspectable
    var bottomGradientColor: UIColor? {
        didSet {
            setGradient(topGradientColor: topGradientColor, bottomGradientColor: bottomGradientColor)
        }
    }
    
    private func setGradient(topGradientColor: UIColor?, bottomGradientColor: UIColor?) {
        DispatchQueue.main.async {
            if let topGradientColor = topGradientColor, let bottomGradientColor = bottomGradientColor {
                self.gradientLayer.frame.size = self.frame.size
                self.gradientLayer.colors = [topGradientColor.cgColor, bottomGradientColor.cgColor]
                self.gradientLayer.borderColor = self.layer.borderColor
                self.gradientLayer.borderWidth = self.layer.borderWidth
                self.gradientLayer.cornerRadius = self.layer.cornerRadius
                self.gradientLayer.startPoint = CGPoint(x: 0, y: 0)
                self.gradientLayer.endPoint = CGPoint(x: 1, y: 0)
                self.layer.insertSublayer(self.gradientLayer, at: 0)
            } else {
                self.gradientLayer.removeFromSuperlayer()
            }
        }
    }
}
extension UIView {
     func dropShadow(scale: Bool = true) {
       layer.masksToBounds = false
       layer.shadowColor = UIColor.black.cgColor
       layer.shadowOpacity = 0.5
       layer.shadowOffset = CGSize(width: -1, height: 1)
       layer.shadowRadius = 1
       layer.shadowPath = UIBezierPath(rect: bounds).cgPath
       layer.shouldRasterize = true
       layer.rasterizationScale = scale ? UIScreen.main.scale : 1
     }
     func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
       layer.masksToBounds = false
       layer.shadowColor = color.cgColor
       layer.shadowOpacity = opacity
       layer.shadowOffset = offSet
       layer.shadowRadius = radius
       layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
       layer.shouldRasterize = true
       layer.rasterizationScale = scale ? UIScreen.main.scale : 1
     }
}
