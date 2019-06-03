//
//  MTextLabel.swift
//  MMText
//
//  Created by Millman on 2019/6/3.
//

import UIKit

class MMTextLabel: UILabel {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup() {
        self.layer.mask = CALayer()
    }
    
    func layoutSubviews() {
        super.layoutSubviews()
    }

}
