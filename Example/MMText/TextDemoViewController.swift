//
//  TextDemoViewController.swift
//  MMText_Example
//
//  Created by Millman on 2019/6/3.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import MMText
class TextDemoViewController: UIViewController {
    @IBOutlet weak var txtView: MMTextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtView.inputViewStyle = .border
        self.txtView.delegate = self
        // Do any additional setup after loading the view.
    }
    @IBAction func errorAction() {
        txtView.errorTitle = "Mutiple line error\nMutiple line error\nMutiple line error\nMutiple line error"
        
    }
    
    @IBAction func clearAction() {
        txtView.errorTitle = nil
    }
    
    
}

extension TextDemoViewController: MMTextViewdProtocol, UITextViewDelegate {
    func textLayoutChanged(text: MMTextView) {
        print("C")
    }
}
