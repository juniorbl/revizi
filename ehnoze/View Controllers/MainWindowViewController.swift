//
//  ViewController.swift
//  ehnoze
//
//  Created by Carlos on 2018-11-17.
//  Copyright © 2018 Carlos Luz. All rights reserved.
//

import Cocoa

class MainWindowViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func newItemBtnClicked(_ sender: Any) {
        print("New item clicked")
    }
}
