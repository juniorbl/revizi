//
//  StoreViewController.swift
//  Revizi
//
//  Created by Carlos on 2019-01-29.
//  Copyright © 2019 Carlos Luz. All rights reserved.
//

import Cocoa

class StoreViewController: NSViewController {
    
    @IBOutlet weak var reviziIcon: NSImageView!
    @IBOutlet weak var priceLabel: NSTextField!
    
    var unlimitedSubjectsPrice: String? {
        didSet { // called every time unlimitedSubjectsPrice changes
            if isViewLoaded {
                priceLabel.stringValue = unlimitedSubjectsPrice ?? ""
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reviziIcon.image = NSImage(named: .reviziLogo)
    }
    
    @IBAction func closeEditTopicWindowAction(_ sender: NSButton) {
        NSApplication.shared.stopModal()
    }
}

extension NSImage.Name {
    static let reviziLogo = NSImage.Name("AppIcon")
}
