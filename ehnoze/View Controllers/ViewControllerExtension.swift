//
//  ViewControllerExtension.swift
//  ehnoze
//
//  Created by Carlos on 2018-12-30.
//  Copyright © 2018 Carlos Luz. All rights reserved.
//

import Foundation
import Cocoa

// functions available to all controllers that extend NSViewController
extension NSViewController {
    
    func displayDialogWith(message: String, informativeText: String = "") {
        let alert = NSAlert.init()
        alert.messageText = message
        alert.informativeText = informativeText
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK") // TODO localize
        alert.runModal()
    }
    
    func displayDialogOkCancel(question: String, infoText: String = "") -> Bool {
        let alert = NSAlert.init()
        alert.messageText = question
        alert.alertStyle = .warning
        alert.informativeText = infoText
        alert.addButton(withTitle: "OK") // TODO localize
        alert.addButton(withTitle: "Cancel") // TODO localize
        return alert.runModal() == .alertFirstButtonReturn
    }
}
