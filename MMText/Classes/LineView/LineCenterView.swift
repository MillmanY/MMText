//
//  LineCenterView.swift
//  MMText
//
//  Created by Millman on 2019/6/3.
//

import UIKit

class LineCenterView: UIView, InputViewProtocol {
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
        layer.lineJoin = .round
        layer.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(layer)
        return layer
    }()
    
    lazy var editLeftLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.lineJoin = .round
        layer.isHidden = true
        layer.fillColor = UIColor.clear.cgColor

        self.layer.addSublayer(layer)
        return layer
    }()
    
    lazy var editRightLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.isHidden = true
        layer.fillColor = UIColor.clear.cgColor
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
        animation.duration = duration
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
        self.reload()
    }
    
    func reload() {
        let bound = self.bounds
        let half = bound.width/2
        
        editLeftLayer.frame = CGRect(x: 0, y: bound.origin.y, width: half, height: bound.height)
        editRightLayer.frame = CGRect(x: half, y: bound.origin.y, width: half, height: bound.height)
        
        lineLayer.frame = bound
        

        switch self.style {
        case .line:
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
        case .boderWith(let radius):
            let bezier = UIBezierPath(roundedRect: self.bounds, cornerRadius: radius)
            bezier.move(to: CGPoint.init(x: bound.maxX, y: bound.height))
            lineLayer.path = bezier.cgPath
            let left = UIBezierPath()
            left.move(to: CGPoint(x: half, y: self.frame.height))
            left.addLine(to: CGPoint(x: radius, y: self.frame.height))
            let leftB = UIBezierPath.init(arcCenter: CGPoint(x: radius, y: self.frame.height-radius),
                                          radius: radius,
                                          startAngle: CGFloat.pi/2, endAngle: CGFloat.pi, clockwise: true)
            left.append(leftB)
            
            left.addLine(to: CGPoint.init(x: 0, y: radius))
            let leftT = UIBezierPath.init(arcCenter: CGPoint(x: radius, y: radius),
                                          radius: radius,
                                          startAngle: CGFloat.pi, endAngle: CGFloat.pi*3/2, clockwise: true)

            left.append(leftT)
            left.addLine(to: CGPoint.init(x: half, y: 0))
            editLeftLayer.path = left.cgPath
            
            
            let right = UIBezierPath()
            right.move(to: CGPoint(x: 0, y: self.frame.height))
            right.addLine(to: CGPoint(x: half-radius, y: self.frame.height))
            let rightB = UIBezierPath.init(arcCenter: CGPoint(x: half-radius, y: self.frame.height-radius),
                                           radius: radius,
                                           startAngle: CGFloat.pi/2, endAngle: 0, clockwise: false)
            right.append(rightB)
            
            right.addLine(to: CGPoint.init(x: half, y: radius))
            let rightT = UIBezierPath.init(arcCenter: CGPoint(x: half-radius, y: radius),
                                          radius: radius,
                                          startAngle: 0, endAngle: -CGFloat.pi/2, clockwise: false)
            right.append(rightT)
            right.addLine(to: .zero)
            editRightLayer.path = right.cgPath
            
        case .border:
            let bezier = UIBezierPath(roundedRect: self.bounds, cornerRadius: 1)
            bezier.move(to: CGPoint.init(x: bound.maxX, y: bound.height))
            lineLayer.path = bezier.cgPath
            
            let left = UIBezierPath()
            left.move(to: CGPoint(x: half, y: self.frame.height))
            left.addLine(to: CGPoint(x: 0, y: self.frame.height))
            left.addLine(to: CGPoint.init(x: 0, y: 0))
            left.addLine(to: CGPoint.init(x: half, y: 0))

            editLeftLayer.path = left.cgPath
            let right = UIBezierPath()
            right.move(to: CGPoint(x: 0, y: self.frame.height))
            right.addLine(to: CGPoint(x: half, y: self.frame.height))
            right.addLine(to: CGPoint(x: half, y: 0))
            right.addLine(to: .zero)
            editRightLayer.path = right.cgPath
        }
    }
}
