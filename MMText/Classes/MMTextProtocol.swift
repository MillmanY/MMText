//
//  MMTextProtocol.swift
//  MMText
//
//  Created by Millman on 2019/6/18.
//

import Foundation
public protocol MMTextFieldProtocol {
    func textLayoutChanged(text: MMTextField)
}

public protocol MMTextViewdProtocol {
    func textLayoutChanged(text: MMTextView)
}
