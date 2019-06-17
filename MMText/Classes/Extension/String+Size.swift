//
//  String+Size.swift
//  MMText
//
//  Created by Millman on 2019/6/4.
//

import Foundation
extension String {
    func calHeightWith(width: CGFloat, font: UIFont?) -> CGFloat {
        
        guard let f = font else {
            return .zero
        }
        
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let textH = (self as NSString).boundingRect(with: size,
                                                 options: .usesLineFragmentOrigin,
                                                 attributes: [NSAttributedString.Key.font: f], context: NSStringDrawingContext()).size.height
        return ceil(textH)
    }
}
