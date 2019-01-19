//
//  PreferencesViewController.swift
//  revizi
//
//  Created by Carlos on 2019-01-12.
//  Copyright © 2019 Carlos Luz. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController {

    @IBOutlet weak var markAsReviewedPopup: NSPopUpButton!
    
    var preferences = Preferences()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateMarkAsReviewedPopup()
    }
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        view.window?.close()
    }
    
    @IBAction func OKButtonClicked(_ sender: Any) {
        preferences.selectedTimeToMarkAsReviewedInSeconds = Double(markAsReviewedPopup.selectedItem?.tag ?? preferences.defaultTimeToMarkAsReviewedInSeconds)
        view.window?.close()
    }
    
    func updateMarkAsReviewedPopup() {
        let existingTimeToMarkAsReviewedInSeconds = Int(preferences.selectedTimeToMarkAsReviewedInSeconds)
        for markAsReviewedOption in markAsReviewedPopup.itemArray {
            if markAsReviewedOption.tag == existingTimeToMarkAsReviewedInSeconds {
                markAsReviewedPopup.select(markAsReviewedOption)
                break
            }
        }
    }
}
