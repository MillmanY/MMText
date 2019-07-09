//
//  LineAnimationView.swift
//  EditText
//
//  Created by Millman on 2019/5/31.
//  Copyright © 2019 Millman. All rights reserved.
//

import UIKit

class LineBaseView: UIView, InputViewProtocol {
    var duration: TimeInterval = 0.3
    var style: InputViewStyle = .line {
        didSet {
            self.reload()
        }
    }
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
    
    var editWidth: CGFloat {
        set {
            self.editLayer.lineWidth = newValue
        } get {
            return self.editLayer.lineWidth
        }
    }
    
    var editColor: UIColor? {
        didSet {
            self.editLayer.strokeColor = editColor?.cgColor
        }
    }
    
    lazy var lineLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(layer)
        return layer
    }()
    
    lazy var editLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
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
        animation.duration = duration == 0 ? 0.001 : duration
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.both
        return animation
    }
    
    func beginEdit() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let animate = self?.animation(isShow: true) else {
                return
            }
            self?.editLayer.isHidden = false
            self?.editLayer.add(animate, forKey: "BeginEdit")
        }
    }
    
    func endEdit() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let animate = self?.animation(isShow: false) else {
                return
            }
            self?.editLayer.isHidden = false
            self?.editLayer.add(animate, forKey: "EndEdit")
        }
    }
    
    func reload() {}
}


class LineLeftAnimateView: LineBaseView {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.reload()
    }

    override func reload() {
        super.reload()
        let bound = self.bounds
        editLayer.frame = bound
        lineLayer.frame = bound
        switch  self.style {
        case .line:
            let bezier = UIBezierPath()
            bezier.move(to: CGPoint(x: 0, y: self.frame.height))
            bezier.addLine(to: CGPoint(x: self.frame.width, y: self.frame.height))
            lineLayer.path = bezier.cgPath
            editLayer.path = bezier.cgPath
        default:
            let bezier = UIBezierPath(roundedRect: self.bounds, cornerRadius: 1)
            lineLayer.path = bezier.cgPath
            editLayer.path = bezier.cgPath
        }

    }
}

class LineRightAnimateView: LineBaseView {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.reload()
    }
    
    override func reload() {
        super.reload()
        let bound = self.bounds
        editLayer.frame = bound
        lineLayer.frame = bound
        
        switch  self.style {
        case .line:
            let bezier = UIBezierPath()
            bezier.move(to: CGPoint(x: self.frame.width, y: self.frame.height))
            bezier.addLine(to: CGPoint(x: 0, y: self.frame.height))
            lineLayer.path = bezier.cgPath
            editLayer.path = bezier.cgPath
        default:
            let bezier = UIBezierPath(roundedRect: self.bounds, cornerRadius: 1)
            bezier.move(to: CGPoint.init(x: bound.maxX, y: bound.height))
            lineLayer.path = bezier.cgPath
            editLayer.path = bezier.cgPath
        }
    }
}
