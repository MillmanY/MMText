//
//  TextVIewTableViewController.swift
//  MMText_Example
//
//  Created by Millman on 2020/3/5.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import MMText
class TextVIewTableViewController: UITableViewController {
    @IBOutlet weak var textView: MMTextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

}

extension TextVIewTableViewController: UITextViewDelegate, MMTextViewdProtocol {
    func textLayoutChanged(text: MMTextView) {

        self.textView.superview?.layoutIfNeeded()
        UIView.setAnimationsEnabled(false)
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
 
    }
}
