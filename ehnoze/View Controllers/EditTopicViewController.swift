//
//  EditTopicViewController.swift
//  ehnoze
//
//  Created by Carlos on 2018-12-02.
//  Copyright © 2018 Carlos Luz. All rights reserved.
//

import Cocoa

class EditTopicViewController: NSViewController {
    @IBOutlet weak var topicName: NSTextField!
    @IBOutlet weak var topicNotes: NSScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func saveTopicAction(_ sender: Any?) {
        let notesTextStorage = (topicNotes.documentView as? NSTextView)?.textStorage
        let notesAttributes = [NSAttributedString.DocumentAttributeKey.documentType: NSAttributedString.DocumentType.plain]
        do {
            let notesData = try notesTextStorage?.data(
                from: NSRange(location: 0, length: notesTextStorage?.string.count ?? 0), documentAttributes: notesAttributes) as! NSData
            TopicMO.save(name: topicName.stringValue, notes: notesData)
        } catch {
            print("Error while saving Topic \(self.className): \(error)")
        }
        NSApplication.shared.stopModal()
    }
    
    @IBAction func closeEditTopicWindowAction(_ sender: NSButton) {
        NSApplication.shared.stopModal()
    }
}
