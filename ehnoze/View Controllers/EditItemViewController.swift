//
//  EditItemViewController.swift
//  ehnoze
//
//  Created by Carlos on 2018-11-27.
//  Copyright © 2018 Carlos Luz. All rights reserved.
//

import Cocoa

class EditItemViewController: NSViewController {
    
    // TODO: maybe user the Item object instead of the properties of the Item
    @objc dynamic var itemName = String()
//    @objc dynamic var itemContents = NSAttributedString()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func closeEditItemWindow(_ sender: NSButton) {
        NSApplication.shared.stopModal()
    }
}
