//
//  EditTopicViewController.swift
//  revizi
//
//  Created by Carlos on 2018-12-02.
//  Copyright © 2018 Carlos Luz. All rights reserved.
//

import Cocoa
import os

class EditTopicViewController: NSViewController {
    
    @IBOutlet weak var topicName: NSTextField!
    @IBOutlet weak var topicNotes: NSScrollView!
    
    var topicToEdit: TopicMO? {
        didSet { // called every time topicToEdit changes
            loadTopicToEdit()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func loadTopicToEdit() {
        if isViewLoaded {
            if let topic = topicToEdit {
                topicName.stringValue = topic.name ?? "No topic name"
                if let topicNotesData = topic.notes {
                    topicNotes.documentView?.insertText(String(data: topicNotesData as Data, encoding: String.Encoding.utf8) ?? "")
                }
            }
        }
    }
    
    @IBAction func saveTopicAction(_ sender: Any?) {
        let notesTextStorage = (topicNotes.documentView as? NSTextView)?.textStorage
        let notesAttributes = [NSAttributedString.DocumentAttributeKey.documentType: NSAttributedString.DocumentType.plain]
        do {
            let notesData = try notesTextStorage?.data(
                from: NSRange(location: 0, length: notesTextStorage?.string.count ?? 0), documentAttributes: notesAttributes) as! NSData
            if let topicToUpdate = topicToEdit {
                if displayErrorMessageIfInvalid({ TopicMO.validateUpdate(newTopicName: topicName.stringValue, originalTopicName: topicToEdit?.name ?? "") }) {
                    return
                }
                topicToUpdate.name = topicName.stringValue
                topicToUpdate.notes = notesTextStorage?.string.data(using: String.Encoding.utf8) as NSData?
                TopicMO.update()
            } else {
                if displayErrorMessageIfInvalid({ TopicMO.validateCreate(topicName.stringValue) }) {
                    return
                }
                TopicMO.save(name: topicName.stringValue, notes: notesData)
            }
        } catch let error as NSError {
            os_log("Error while saving Topic: %s", error)
        }
        NSApplication.shared.stopModal()
    }
    
    @IBAction func closeEditTopicWindowAction(_ sender: NSButton) {
        NSApplication.shared.stopModal()
    }
}
