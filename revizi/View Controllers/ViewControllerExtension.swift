//
//  ViewControllerExtension.swift
//  revizi
//
//  Created by Carlos Luz on 2018-12-30.
//

import Cocoa

// functions available to all controllers that extend NSViewController
extension NSViewController {
    
    func displayDialogWith(message: String, informativeText: String = "") {
        let alert = NSAlert.init()
        alert.messageText = message
        alert.informativeText = informativeText
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    func displayDialogOkCancel(question: String, infoText: String = "") -> Bool {
        let alert = NSAlert.init()
        alert.messageText = question
        alert.alertStyle = .warning
        alert.informativeText = infoText
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        return alert.runModal() == .alertFirstButtonReturn
    }
    
    func displayErrorMessageIfInvalid(_ function: () -> String?) -> Bool {
        let errorMessage = function()
        if errorMessage != nil {
            displayDialogWith(message: errorMessage!)
            return true
        }
        return false
    }
}
