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
    @IBOutlet weak var buyButton: NSButton!
    
    var unlimitedSubjectsPrice: String? {
        didSet { // called every time unlimitedSubjectsPrice changes
            if isViewLoaded {
                priceLabel.stringValue = unlimitedSubjectsPrice ?? ""
                verifyPermissionToMakePayments()
            }
        }
    }
    
    private func verifyPermissionToMakePayments() {
        if !StoreHelper.canMakePayments() {
            buyButton.isEnabled = false
            priceLabel.stringValue = "Not available" // TODO localize
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reviziIcon.image = NSImage(named: .reviziLogo)
    }
    
    @IBAction func buyUnlimitedSubjects(_ sender: Any) {
        UnlimitedSubjects.store.fetchAvailableProducts{ [weak self] success, availableProducts in
            guard let self = self else { return }
            if success {
                if availableProducts?.count == 1 { // hard coded, as of january 2019 there's only one in-app product and there's no plan to add more
                    for product in availableProducts! {
                        UnlimitedSubjects.store.buyProduct(product)
                        NSApplication.shared.stopModal()
                        break
                    }
                }
            }
        }
    }
    
    @IBAction func closeEditTopicWindowAction(_ sender: NSButton) {
        NSApplication.shared.stopModal()
    }
}

extension NSImage.Name {
    static let reviziLogo = NSImage.Name("AppIcon")
}
