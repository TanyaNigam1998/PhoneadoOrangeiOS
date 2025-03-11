//
//  Designables.swift
//  Phoneado
//
//  Created by Zimble on 3/23/22.
//

import Foundation
import UIKit

@IBDesignable class GradientView: UIView {
    @IBInspectable
    public var firstColor: UIColor = .white {
        didSet {
            gradientLayer.colors = [firstColor.cgColor, secondColor.cgColor]
            setNeedsDisplay()
        }
    }
    @IBInspectable
    public var secondColor: UIColor = .white {
        didSet {
            gradientLayer.colors = [firstColor.cgColor, secondColor.cgColor]
            setNeedsDisplay()
        }
    }
    @IBInspectable var vertical: Bool = true {
        didSet {
            updateGradientDirection()
        }
    }
    lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [firstColor.cgColor, secondColor.cgColor]
        layer.startPoint = CGPoint.zero
        return layer
    }()
    // MARK: - Lifecycle
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        applyGradient()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        applyGradient()
    }
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        applyGradient()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        updateGradientFrame()
    }
    // MARK: - Helper
    func applyGradient() {
        updateGradientDirection()
        layer.sublayers = [gradientLayer]
    }
    func updateGradientFrame() {
        gradientLayer.frame = bounds
    }
    func updateGradientDirection() {
        gradientLayer.endPoint = vertical ? CGPoint(x: 0, y: 1) : CGPoint(x: 1, y: 0)
    }
}
