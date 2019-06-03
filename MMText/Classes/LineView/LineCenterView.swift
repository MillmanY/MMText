//
//  LineCenterView.swift
//  MMText
//
//  Created by Millman on 2019/6/3.
//

import UIKit

class LineCenterView: UIView, LineViewProtocol {
    var lineWidth: CGFloat {
        set {
            self.lineLayer.lineWidth = newValue
        } get {
            return self.lineLayer.lineWidth
        }
    }
    
    var lineColor: UIColor? {
        didSet {
            self.lineLayer.strokeColor = lineColor?.cgColor
        }
    }
    
    var editWidth: CGFloat = 0.0 {
        didSet {
            self.editLeftLayer.lineWidth = editWidth
            self.editRightLayer.lineWidth = editWidth
        }
    }
    
    var editColor: UIColor? {
        didSet {
            self.editLeftLayer.strokeColor = editColor?.cgColor
            self.editRightLayer.strokeColor = editColor?.cgColor
        }
    }
    
    lazy var lineLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        self.layer.addSublayer(layer)
        return layer
    }()
    
    lazy var editLeftLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.isHidden = true
        self.layer.addSublayer(layer)
        return layer
    }()
    
    lazy var editRightLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.isHidden = true
        self.layer.addSublayer(layer)
        return layer
    }()

    
    func animation(isShow:Bool) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        if isShow {
            animation.fromValue = 0.0
            animation.toValue = 1.0
        } else {
            animation.fromValue = 1.0
            animation.toValue = 0.0
        }
        animation.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeIn)
        animation.duration = 0.3
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.both
        return animation
    }
    
    func beginEdit() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let animate = self?.animation(isShow: true) else {
                return
            }
            self?.editLeftLayer.isHidden = false
            self?.editLeftLayer.add(animate, forKey: "Show")
            self?.editRightLayer.isHidden = false
            self?.editRightLayer.add(animate, forKey: "Show")
        }
    }
    
    func endEdit() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let animate = self?.animation(isShow: false) else {
                return
            }
            self?.editLeftLayer.isHidden = false
            self?.editLeftLayer.add(animate, forKey: "Show")
            self?.editRightLayer.isHidden = false
            self?.editRightLayer.add(animate, forKey: "Show")
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let bound = self.bounds
        let half = bound.width/2
        
        editLeftLayer.frame = CGRect(x: 0, y: bound.origin.y, width: half, height: bound.height)
        editRightLayer.frame = CGRect(x: half, y: bound.origin.y, width: half, height: bound.height)

        lineLayer.frame = bound
        let bezier = UIBezierPath()
        bezier.move(to: CGPoint(x: self.frame.width, y: self.frame.height))
        bezier.addLine(to: CGPoint(x: 0, y: self.frame.height))
        lineLayer.path = bezier.cgPath
        
        let left = UIBezierPath()
        left.move(to: CGPoint(x: half, y: self.frame.height))
        left.addLine(to: CGPoint(x: 0, y: self.frame.height))
        editLeftLayer.path = left.cgPath
        
        let right = UIBezierPath()
        right.move(to: CGPoint(x: 0, y: self.frame.height))
        right.addLine(to: CGPoint(x: half, y: self.frame.height))
        editRightLayer.path = right.cgPath
    }
}
