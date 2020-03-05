//
//  MMTextField.swift
//  EditText
//
//  Created by Millman on 2019/5/30.
//  Copyright © 2019 Millman. All rights reserved.
//

import UIKit

extension MMTextField {
    public enum LineType {
        case left
        case center
        case right
    }
}



@IBDesignable
open class MMTextField: UITextField {
    public var duration: TimeInterval = 0.3 {
        didSet {
            lineView.duration = duration
        }
    }
    private var layoutChanged: (()->Void)?
    private static var systemPlaceHolderColor = UIColor(red: 0, green: 0, blue: 0.0980392, alpha: 0.22)
    var tes: UIView = UIView()

    var lineView: UIView & InputViewProtocol = LineLeftAnimateView()
    
    public func onLayoutChanged(block: (()->Void)?) {
        self.layoutChanged = block
    }
    
    private var shiftPlaceholderTitle: Bool = false {
        didSet {
            self.updatePlaceHolderFont()
            if shiftPlaceholderTitle {
                placeHolderLabel.textColor = self.textColor
                placeHolderLabel.mmTextLayout.setTop(anchor: self.topAnchor, type: .equal(constant: 0))
                    .setHeight(type: .equalTo(anchor: self.titleLabel.heightAnchor, multiplier: 1, constant: 0))
            } else {
                placeHolderLabel.textColor = MMTextField.systemPlaceHolderColor
                placeHolderLabel.mmTextLayout
                    .setTop(anchor: self.lineContainerView.topAnchor, type: .equal(constant: 0))
                    .setHeight(type: .equalTo(anchor: self.lineContainerView.heightAnchor, multiplier: 1, constant: 0))
            }
            UIView.animate(withDuration: 0.1) { self.layoutIfNeeded() }
            
        }
    }

    private lazy var lineContainerView: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = false
        v.backgroundColor = UIColor.clear
        v.clipsToBounds = false
        self.addSubview(v)
        return v
    }()
        
    private var placeHolderLabel: UILabel = {
        let label = UILabel()
        label.textColor = MMTextField.systemPlaceHolderColor
        label.isUserInteractionEnabled = false
        return label
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 12)
        label.isUserInteractionEnabled = false
        return label
    }()
    
    lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.backgroundColor = UIColor.clear
        label.font = UIFont.systemFont(ofSize: 14)
        label.isUserInteractionEnabled = false
        self.addSubview(label)
        return label
    }()
    
    public var titleFont: UIFont? {
        didSet {
            self.updatePlaceHolderFont()
            self.titleLabel.font = titleFont
            self.invalidateIntrinsicContentSize()
            self.layoutIfNeeded()
            self.layoutChanged?()
            (self.delegate as? MMTextFieldProtocol)?.textLayoutChanged(text: self)
        }
    }
    
    public var errorFont: UIFont? {
        didSet {
            self.errorLabel.font = errorFont
            self.invalidateIntrinsicContentSize()
            self.layoutIfNeeded()
            self.layoutChanged?()
            (self.delegate as? MMTextFieldProtocol)?.textLayoutChanged(text: self)
        }
    }
    
    public var lineType: LineType = .left {
        didSet {
            lineView.removeFromSuperview()
            switch lineType {
            case .left:
                lineView = LineLeftAnimateView()
            case .right:
                lineView = LineRightAnimateView()
            case .center:
                lineView = LineCenterView()
            }
            lineView.duration = duration
            lineView.lineWidth = CGFloat(lineWidth)
            lineView.lineColor = lineColor
            lineView.editWidth = CGFloat(editLineWidth)
            lineView.editColor = editLineColor
            self.lineContainerView.addSubview(lineView)
            lineView.mmTextLayout
                .setTop(anchor: self.lineContainerView.topAnchor, type: .equal(constant: 0))
                .setLeading(anchor: self.lineContainerView.leadingAnchor, type: .equal(constant: 0))
                .setTrailing(anchor: self.lineContainerView.trailingAnchor, type: .equal(constant: 0))
                .setBottom(anchor: self.lineContainerView.bottomAnchor, type: .equal(constant: 0))
        }
    }
    
    public var inputViewStyle: InputViewStyle {
        set {
            lineView.style = newValue
            self.updatePlaceHolderMargin()
            self.invalidateIntrinsicContentSize()
            self.layoutIfNeeded()
        } get {
            return lineView.style
        }
    }
    
    // MARK: - Public Parameter
    @IBInspectable
    public var titleFromPlaceHolder: Bool = false {
        didSet {
            self.titleLabel.text = titleFromPlaceHolder ? placeholder : title
        }
    }
   
    @IBInspectable
    public var title: String?  {
        set {
            if titleFromPlaceHolder { return }
            self.titleLabel.text = newValue
            self.titleLabel.sizeToFit()
            titleLabel.mmTextLayout[.bottom]?.constant = -realTopMargin
            self.invalidateIntrinsicContentSize()
            self.layoutIfNeeded()
            self.layoutChanged?()
            (self.delegate as? MMTextFieldProtocol)?.textLayoutChanged(text: self)

        } get {
            return self.titleLabel.text
        }
    }
    
    public var attributeTitle: NSAttributedString? {
        set {
            if titleFromPlaceHolder { return }
            self.titleLabel.attributedText = newValue
            self.titleLabel.sizeToFit()
            titleLabel.mmTextLayout[.bottom]?.constant = -realTopMargin
            self.invalidateIntrinsicContentSize()
            self.layoutIfNeeded()
            self.layoutChanged?()
            (self.delegate as? MMTextFieldProtocol)?.textLayoutChanged(text: self)
            
        } get {
            return self.titleLabel.attributedText
        }
    }

    @IBInspectable
    public var titleMargin: CGFloat = 5 {
        didSet {
            titleLabel.mmTextLayout[.bottom]?.constant = -realTopMargin
            self.invalidateIntrinsicContentSize()
            self.layoutIfNeeded()
            self.layoutChanged?()
            (self.delegate as? MMTextFieldProtocol)?.textLayoutChanged(text: self)
        }
    }
    
    @IBInspectable
    public var titleColor: UIColor = UIColor.black {
        didSet {
            self.titleLabel.textColor = titleColor
        }
    }
    
    @IBInspectable
    public var errorTitle: String? = nil {
        didSet {
            self.errorLabel.text = errorTitle
            self.errorLabel.sizeToFit()
            errorLabel.mmTextLayout[.top]?.constant = realBottomMargin
            self.invalidateIntrinsicContentSize()
            self.layoutIfNeeded()
            self.layoutChanged?()
            (self.delegate as? MMTextFieldProtocol)?.textLayoutChanged(text: self)
        }
    }
    
    public var errorAttributeTitle: NSAttributedString? = nil {
        didSet {
            self.errorLabel.attributedText = errorAttributeTitle
            self.errorLabel.sizeToFit()
            errorLabel.mmTextLayout[.top]?.constant = realBottomMargin
            self.invalidateIntrinsicContentSize()
            self.layoutIfNeeded()
            self.layoutChanged?()
            (self.delegate as? MMTextFieldProtocol)?.textLayoutChanged(text: self)
        }
    }
    
    @IBInspectable
    public var errorMargin: CGFloat = 5 {
        didSet {
            errorLabel.mmTextLayout[.top]?.constant = realBottomMargin
            self.invalidateIntrinsicContentSize()
            self.layoutIfNeeded()
            self.layoutChanged?()
            (self.delegate as? MMTextFieldProtocol)?.textLayoutChanged(text: self)
        }
    }
    
    @IBInspectable
    public var errorColor: UIColor = UIColor.red {
        didSet {
            self.errorLabel.textColor = errorColor
        }
    }
    
    @IBInspectable
    public var lineWidth:Float = 1 {
        didSet {
            self.lineView.lineWidth = CGFloat(lineWidth)
            self.updatePlaceHolderMargin()
        }
    }
    
    @IBInspectable
    public var lineColor: UIColor? {
        didSet {
            self.lineView.lineColor = lineColor
        }
    }
    
    @IBInspectable
    public var editLineWidth:Float = 2 {
        didSet {
            self.lineView.editWidth = CGFloat(editLineWidth)
            self.updatePlaceHolderMargin()
        }
    }
    
    @IBInspectable
    public var editLineColor: UIColor? {
        didSet {
            self.lineView.editColor = editLineColor
        }
    }
    
    override open var textColor: UIColor? {
        didSet {
            self.tintColor = textColor
        }
    }

    override open var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        lineContainerView.mmTextLayout[.height]?.constant = size.height + 8
        size.height += (realTopHeight+realBottomHeight)
        return size
    }
    
    override open var font: UIFont? {
        didSet {
            self.updatePlaceHolderFont()
        }
    }
   
    override open var placeholder: String? {
        didSet {
            self.placeHolderLabel.text = placeholder
        }
    }
    
    override open var text: String? {
        didSet {
            self.valueChange()
        }
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        self.superview?.layoutIfNeeded()
    }
    
    override open var attributedText: NSAttributedString? {
        didSet {
            self.valueChange()
        }
    }
    
    override open var textAlignment: NSTextAlignment {
        didSet {
            self.titleLabel.textAlignment = textAlignment
            self.errorLabel.textAlignment = textAlignment
            self.placeHolderLabel.textAlignment = textAlignment
        }
    }
    
    override open func drawPlaceholder(in rect: CGRect) {
       self.titleLabel.isHidden = titleFromPlaceHolder
       self.placeHolderLabel.text = placeholder
    }
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return self.fixText(rect: super.textRect(forBounds: bounds))
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return self.fixText(rect: super.editingRect(forBounds: bounds))
    }
    
    override open func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        let r = super.clearButtonRect(forBounds: self.lineContainerView.frame)
        return r
    }
    
    override open func borderRect(forBounds bounds: CGRect) -> CGRect {
        return super.borderRect(forBounds: bounds)
    }
    
    override open func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var r = super.leftViewRect(forBounds: bounds)
        r.origin.y = realTopHeight + (lineContainerView.frame.height-r.height)/2
        return r
    }
    
    override open func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var r = super.rightViewRect(forBounds: bounds)
        r.origin.y = realTopHeight + (lineContainerView.frame.height-r.height)/2
        return r
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    open func setup() {
        self.tintColor = textColor
        self.lineType = .left
        let t = self.textAlignment
        self.updatePlaceHolderFont()
        self.textAlignment = t
        self.addSubview(titleLabel)
        self.addSubview(placeHolderLabel)
        self.lineContainerView.addSubview(self.lineView)
        self.editLineWidth = 2
        self.lineWidth = 1
        self.lineColor = self.textColor
        self.editLineColor = self.textColor
        self.addTarget(self, action: #selector(MMTextField.beginEdit), for: .editingDidBegin)
        self.addTarget(self, action: #selector(MMTextField.endEdit), for: .editingDidEnd)
        self.addTarget(self, action: #selector(MMTextField.valueChange), for: .editingChanged)
        titleLabel.setContentHuggingPriority(.init(750), for: .vertical)
        titleLabel.mmTextLayout
            .setTop(anchor: self.topAnchor, type: .equal(constant: 0))
            .setLeft(anchor: self.leftAnchor, type: .equal(constant: 0))
            .setRight(anchor: self.rightAnchor, type: .equal(constant: 0))
            .setBottom(anchor: self.lineContainerView.topAnchor, type: .equal(constant: 0))
        
        lineContainerView.setContentHuggingPriority(.init(749), for: .vertical)
        lineContainerView.mmTextLayout
            .setLeading(anchor: self.leadingAnchor, type: .equal(constant: 0))
            .setTrailing(anchor: self.trailingAnchor, type: .equal(constant: 0))
            .setHeight(type: .greaterThanOrEqual(constant: 0))
        
        errorLabel.setContentHuggingPriority(.init(750), for: .vertical)
        errorLabel.mmTextLayout
            .setTop(anchor: self.lineContainerView.bottomAnchor, type: .equal(constant: 0))
            .setLeading(anchor: self.leadingAnchor, type: .equal(constant: 0))
            .setTrailing(anchor: self.trailingAnchor, type: .equal(constant: 0))
            .setBottom(anchor: self.bottomAnchor, type: .equal(constant: 0))
        placeHolderLabel.mmTextLayout
            .setTop(anchor: self.lineContainerView.topAnchor, type: .equal(constant: 0))
            .setLeading(anchor: self.lineContainerView.leadingAnchor, type: .equal(constant: 0))
            .setTrailing(anchor: self.lineContainerView.trailingAnchor, type: .equal(constant: 0))
            .setHeight(type: .equalTo(anchor: self.lineContainerView.heightAnchor, multiplier: 1.0, constant: 0.0))
    }

}

extension MMTextField {
    
    private func updatePlaceHolderMargin() {
        switch inputViewStyle {
        case .border, .boderWith(_):
            let parameter: CGFloat = self.textAlignment == .right ? -1 : 1
            
            let maxLine = max(lineWidth, editLineWidth)
            let x = (CGFloat(maxLine/2) + 5)
            placeHolderLabel.mmTextLayout[.leading]?.constant = x
            placeHolderLabel.mmTextLayout[.trailing]?.constant = x*parameter
            
        case .line:
            placeHolderLabel.mmTextLayout[.leading]?.constant = 0
            placeHolderLabel.mmTextLayout[.trailing]?.constant = 0
        }
    }
    
    private func fixText(rect: CGRect) -> CGRect {
        var r = rect
        
        switch self.inputViewStyle {
        case .border, .boderWith(_):
            let maxLine = max(lineWidth, editLineWidth)
            let parameter: CGFloat = self.textAlignment == .right ? -1 : 1
            r.origin.x += (CGFloat(maxLine/2) + 5)*parameter
        case .line:
            break
        }
        
        
        if realBottomHeight == 0 && realTopHeight != 0 {
            r.origin.y += (realTopHeight)/2
        } else if realBottomHeight != 0 && realTopHeight == 0 {
            r.origin.y -= (realBottomHeight)/2
        } else {
            r.origin.y += (realTopHeight-realBottomHeight)/2
        }
        return r
    }
    private var realTopHeight: CGFloat {
        return titleLabel.frame.height > 0 ? titleLabel.frame.height + titleMargin : 0
    }
    
    private var realBottomHeight: CGFloat {
        return errorLabel.frame.height > 0 ? errorLabel.frame.height + errorMargin : 0
    }
    
    private var realTopMargin: CGFloat {
        return titleLabel.frame.height > 0 ? titleMargin : 0
    }
    
    private var realBottomMargin: CGFloat {
        return errorLabel.frame.height > 0 ? errorMargin : 0
    }
    
    private func updatePlaceHolderFont() {
        placeHolderLabel.font = shiftPlaceholderTitle ? titleLabel.font : self.font
    }
    
    @objc func beginEdit() {
        lineView.beginEdit()
        self.valueChange()
        if self.titleFromPlaceHolder {
            self.shiftPlaceholderTitle = true
        }
    }
    
    @objc func endEdit() {
        lineView.endEdit()
        self.valueChange()
        if self.titleFromPlaceHolder {
            self.shiftPlaceholderTitle = false
        }
    }

    @objc func valueChange() {
        let textNotEmpty = self.text?.isEmpty == false || self.attributedText?.string.isEmpty == false
        if titleFromPlaceHolder {
            self.placeHolderLabel.isHidden = textNotEmpty && !self.isEditing
        } else {
            self.placeHolderLabel.isHidden = textNotEmpty
        }
    }
}

