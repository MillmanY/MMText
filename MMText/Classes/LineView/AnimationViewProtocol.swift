//
//  AnimationViewProtocol.swift
//  EditText
//
//  Created by Millman on 2019/5/31.
//  Copyright © 2019 Millman. All rights reserved.
//

import Foundation
public enum InputViewStyle {
    case line
    case border
}

protocol InputViewProtocol: class {
    var duration: TimeInterval {set get}
    func beginEdit()
    func endEdit()
    var lineWidth: CGFloat {set get}
    var lineColor: UIColor? {set get}
    var editWidth: CGFloat {set get}
    var editColor: UIColor? {set get}
    var style: InputViewStyle {set get}
    func reload()
//    var lineLayer: CAShapeLayer {set get}
//    var editLayer: CAShapeLayer {set get}
}
