//
//  ViewController.swift
//  MMText
//
//  Created by MillmanY on 06/01/2019.
//  Copyright (c) 2019 MillmanY. All rights reserved.
//

import UIKit
import MMText

class ViewController: UIViewController {
    @IBOutlet weak var txtAccount1: MMTextField!
    @IBOutlet weak var txtPwd1: MMTextField!
    @IBOutlet weak var txtAccount2: MMTextField!
    @IBOutlet weak var txtPwd2: MMTextField!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtPwd2.lineType = .right
        txtAccount2.lineType = .center
        // Do any additional setup after loading the view.
    }
    
    @IBAction func errorAction() {
        txtPwd1.errorTitle = "Mutiple line error\nMutiple line error\nMutiple line error\nMutiple line error"
        txtAccount1.errorTitle = "Your account is error"

        txtAccount2.errorTitle = "Your account is error"
        txtPwd2.errorTitle = "Mutiple line error\nMutiple line error\nMutiple line error\nMutiple line error"
    }
    
    @IBAction func clearAction() {
        txtAccount1.errorTitle = nil
        txtPwd1.errorTitle = nil
        txtAccount2.errorTitle = nil
        txtPwd2.errorTitle = nil
    }
    
    @IBAction func inputBorderAction() {
        txtAccount1.inputViewStyle = .border
        txtPwd1.inputViewStyle = .border
        txtAccount2.inputViewStyle = .border
        txtPwd2.inputViewStyle = .border

    }
}

