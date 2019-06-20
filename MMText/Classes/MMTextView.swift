//
//  MMTextView.swift
//  MMText
//
//  Created by Millman on 2019/6/3.
//

import Foundation
import UIKit

extension MMTextView {
    public enum LineType {
        case left
        case center
        case right
    }
}

@IBDesignable
open class MMTextView: UITextView {
    private var layoutChanged: (()->Void)?
    private var boundObserver: NSKeyValueObservation?
    private static var defaultMargin: CGFloat = 8
    private static var systemPlaceHolderColor = UIColor(red: 0, green: 0, blue: 0.0980392, alpha: 0.22)
    var equalContent = true
    private var coverView: UIView = {
       let v = UIView()
        v.clipsToBounds = false
        v.isUserInteractionEnabled = false
        return v
    }()
    
    private var showMask: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.red
        return view
    }()
    
    override open var contentSize: CGSize {
        didSet {
            self.invalidateIntrinsicContentSize()
            self.layoutIfNeeded()
            self.setNeedsLayout()
            self.updateMaskFrame()
            self.delayLayoutChange()
        }
    }
    
    override open var contentOffset: CGPoint {
        didSet {
            self.updateMaskFrame()
        }
    }
    
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    open override func didMoveToWindow() {
        super.didMoveToWindow()
        if let superV = self.superview, superV != coverView.superview {
            superV.addSubview(coverView)
            coverView.mmTextLayout
                .setTop(anchor: self.topAnchor, type: .equal(constant: 0))
                .setLeading(anchor: self.leadingAnchor, type: .equal(constant: 0))
                .setTrailing(anchor: self.trailingAnchor, type: .equal(constant: 0))
                .setBottom(anchor: self.bottomAnchor, type: .equal(constant: 0))
        }
    }
    
    
    
    open func setup() {
        
        self.textContainer.lineFragmentPadding = 0
        self.placeHolderLabel.textContainer.lineFragmentPadding = 0
        NotificationCenter.default.addObserver(forName: UITextView.textDidBeginEditingNotification, object: nil, queue: OperationQueue.main) { [weak self] (value) in
            if let o = value.object as? UITextView , o == self {
                self?.beginEdit()
            }
        }
        
        NotificationCenter.default.addObserver(forName: UITextView.textDidEndEditingNotification, object: nil, queue: OperationQueue.main) { [weak self] (value) in
            if let o = value.object as? UITextView , o == self {
                self?.endEdit()
            }
        }
        
        NotificationCenter.default.addObserver(forName: UITextView.textDidChangeNotification, object: nil, queue: OperationQueue.main) { [weak self] (value) in
            if let o = value.object as? UITextView , o == self {
                self?.valueChange()
            }
        }
        

        self.mask = showMask
        self.clipsToBounds = false
        self.lineType = .left
        let t = self.textAlignment
        self.textAlignment = t
        
        coverView.addSubview(lineContainerView)
        coverView.addSubview(titleLabel)
        coverView.addSubview(placeHolderLabel)
        coverView.addSubview(errorLabel)
        self.errorColor = UIColor.red
        self.titleColor = UIColor.black
        self.lineContainerView.addSubview(self.lineView)
        self.editLineWidth = 2
        self.lineWidth = 1
        self.placeHolderLabel.font = font
        titleLabel.setContentHuggingPriority(.init(750), for: .vertical)
        titleLabel.mmTextLayout
            .setTop(anchor: coverView.topAnchor, type: .equal(constant: 0))
            .setLeading(anchor: self.lineContainerView.leadingAnchor, type: .equal(constant: 0))
            .setTrailing(anchor: self.lineContainerView.trailingAnchor, type: .equal(constant: 0))
            .setBottom(anchor: self.lineContainerView.topAnchor, type: .equal(constant: 0))
        
        lineContainerView.setContentHuggingPriority(.init(749), for: .vertical)
        lineContainerView.mmTextLayout
            .setCenterX(anchor: coverView.centerXAnchor, type: .equal(constant: 0))
            .setWidth(type: .equalTo(anchor: coverView.widthAnchor, multiplier: 1, constant: 0))
        errorLabel.setContentHuggingPriority(.init(750), for: .vertical)
        errorLabel.mmTextLayout
            .setTop(anchor: self.lineContainerView.bottomAnchor, type: .equal(constant: 0))
            .setLeading(anchor: self.lineContainerView.leadingAnchor, type: .equal(constant: 0))
            .setTrailing(anchor: self.lineContainerView.trailingAnchor, type: .equal(constant: 0))
            .setBottom(anchor: coverView.bottomAnchor, type: .equal(constant: 0))
        
        placeHolderLabel.mmTextLayout
            .setTop(anchor: self.lineContainerView.topAnchor, type: .equal(constant: 0))
            .setCenterX(anchor: self.lineContainerView.centerXAnchor, type: .equal(constant: 0))
            .setWidth(type: .equalTo(anchor: self.lineContainerView.widthAnchor, multiplier: 1, constant: 0))
            .setBottom(anchor: self.lineContainerView.bottomAnchor, type: .equal(constant: 0))
        lineContainerView.layoutIfNeeded()
     

        boundObserver  = lineContainerView.observe(\.bounds, options: [.initial,.new]) { [weak self] (_, value) in
            guard let _ = value.newValue else {
                return
            }
            self?.updateMaskFrame()
            self?.delayLayoutChange()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) { [weak self] in
            self?.layoutIfNeeded()
            self?.invalidateIntrinsicContentSize()
            self?.tintColor = self?.lineColor
        }
    }

    
    private var lineView: UIView & InputViewProtocol = LineLeftAnimateView()
    
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
                placeHolderLabel.textColor = MMTextView.systemPlaceHolderColor
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
        return v
    }()
    
    private var placeHolderLabel: UITextView = {
        let label = UITextView()
        label.backgroundColor = UIColor.clear
        label.isScrollEnabled = false
        label.clipsToBounds = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = MMTextView.systemPlaceHolderColor
        label.isUserInteractionEnabled = false
        return label
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 12)
        label.isUserInteractionEnabled = false
        return label
    }()
    
    private var errorLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.backgroundColor = UIColor.clear
        label.font = UIFont.systemFont(ofSize: 14)
        label.isUserInteractionEnabled = false
        return label
    }()
    
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
    
    public var titleFont: UIFont? {
        didSet {
            self.updatePlaceHolderFont()
            self.titleLabel.font = titleFont
            self.invalidateIntrinsicContentSize()
            self.layoutIfNeeded()
            self.layoutChanged?()
            (self.delegate as? MMTextViewdProtocol)?.textLayoutChanged(text: self)
        }
    }
    
    public var errorFont: UIFont? {
        didSet {
            self.errorLabel.font = errorFont
            self.invalidateIntrinsicContentSize()
            self.layoutIfNeeded()
            self.layoutChanged?()
            (self.delegate as? MMTextViewdProtocol)?.textLayoutChanged(text: self)
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
            (self.delegate as? MMTextViewdProtocol)?.textLayoutChanged(text: self)
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
            (self.delegate as? MMTextViewdProtocol)?.textLayoutChanged(text: self)
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
            (self.delegate as? MMTextViewdProtocol)?.textLayoutChanged(text: self)

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
            (self.delegate as? MMTextViewdProtocol)?.textLayoutChanged(text: self)
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
            (self.delegate as? MMTextViewdProtocol)?.textLayoutChanged(text: self)
        }
    }
    
    @IBInspectable
    public var errorMargin: CGFloat = 5 {
        didSet {
            errorLabel.mmTextLayout[.top]?.constant = realBottomMargin
            self.invalidateIntrinsicContentSize()
            self.layoutIfNeeded()
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
    public var lineColor: UIColor? = UIColor.black {
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
    public var editLineColor: UIColor? = UIColor.black {
        didSet {
            self.lineView.editColor = editLineColor
        }
    }
    
    override open var textColor: UIColor? {
        didSet {
            self.tintColor = textColor
        }
    }
    
    override open var font: UIFont? {
        didSet {
            self.updatePlaceHolderFont()
        }
    }
    
    override open var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        let topBotMargin = realTopHeight+realBottomHeight
        let width = self.textContainer.size.width
        let font = self.font
        let placeHeight = (self.placeHolderLabel.text ?? "").calHeightWith(width: width, font: font)
        var textHeight = (self.text ?? "").calHeightWith(width: width, font: font)
        let textH = max(textHeight,placeHeight) + 2*MMTextView.defaultMargin
        if textHeight > self.contentSize.height {
            textHeight = self.contentSize.height
            self.isScrollEnabled = true
        } else {
            self.isScrollEnabled = false
        }
        size.height = topBotMargin + textH
        self.textContainerInset = UIEdgeInsets(top: realTopHeight+MMTextView.defaultMargin,
                                               left: 0,
                                               bottom: realBottomHeight+MMTextView.defaultMargin,
                                               right: 0)
        return size
    }
    @IBInspectable
    public var placeholder: String? {
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
}

extension MMTextView {
  
    @objc private func _delayLayoutChange() {
        (self.delegate as? MMTextViewdProtocol)?.textLayoutChanged(text: self)
    }
    
    func delayLayoutChange() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(_delayLayoutChange), object: nil)
        self.perform(#selector(_delayLayoutChange), with: nil, afterDelay: 0.1)
    }
    private func updateMaskFrame() {
        let height = lineContainerView.frame.height
        let y = realTopHeight+self.contentOffset.y
        let f = CGRect(x: 0, y: y, width: lineContainerView.frame.width, height: height)

        if f != self.mask?.frame {
            self.mask?.frame = f
        }
    }
    private func updatePlaceHolderMargin() {
        switch inputViewStyle {
        case .border:
            let maxLine = max(lineWidth, editLineWidth)
            let x = (CGFloat(maxLine/2) + 5)
            lineContainerView.mmTextLayout[.width]?.constant = 2*x
            placeHolderLabel.mmTextLayout[.width]?.constant = -2*x
        case .line:
            lineContainerView.mmTextLayout[.width]?.constant = 0
            placeHolderLabel.mmTextLayout[.width]?.constant = 0
        }
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
            self.placeHolderLabel.isHidden = textNotEmpty && !self.isFocused
        } else {
            self.placeHolderLabel.isHidden = textNotEmpty
        }
    }
}
