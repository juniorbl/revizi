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
    @IBOutlet weak var limitReachedLabel: NSTextField!
    @IBOutlet weak var priceLabel: NSTextField!
    
    var displaySubjectLimitMessage: Bool? {
        didSet { // called every time displaySubjectLimitMessage changes
            if isViewLoaded && displaySubjectLimitMessage ?? false {
                limitReachedLabel.stringValue = "Maximum free subject count reached" // TODO localize
            }
        }
    }
    
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
    
    //            displayDialogWith(message: "Maximum free subject count reached", informativeText: "If you feel Revizi is useful to you, consider unlocking unlimited subjects, you will be able to create as many subjects as you want and support the continuous development of Revizi.") // TODO localize
    
    @IBAction func closeEditTopicWindowAction(_ sender: NSButton) {
        NSApplication.shared.stopModal()
    }
}

extension NSImage.Name {
    static let reviziLogo = NSImage.Name("AppIcon")
}
