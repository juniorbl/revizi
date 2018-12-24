//
//  EditItemSubjectController.swift
//  ehnoze
//
//  Created by Carlos on 2018-11-27.
//  Copyright © 2018 Carlos Luz. All rights reserved.
//

import Cocoa

class EditSubjectViewController: NSViewController {
    
    var subjectToEdit: SubjectMO? {
        didSet { // called every time subjectToEdit changes
            loadSubjectToEdit()
        }
    }
    @IBOutlet weak var parentTopicComboBox: NSComboBox!
    @IBOutlet weak var subjectNotesField: NSTextField!
    @IBOutlet weak var subjectContentsField: NSScrollView!
    @IBOutlet weak var subjectNameField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTopics()
    }
    
    func loadTopics() {
        parentTopicComboBox.addItems(withObjectValues: TopicMO.fetchAll().map({$0.name ?? ""}))
    }
    
    func loadSubjectToEdit() {
        if isViewLoaded {
            if let subject = subjectToEdit {
                subjectNameField.stringValue = subject.name ?? "Error: no subject name"
                parentTopicComboBox.selectItem(withObjectValue: subject.parentTopic?.name)
                subjectNotesField.stringValue = subject.notes ?? ""
                subjectContentsField.documentView?.insertText(subject.contentsAsString())
            }
        }
    }
    
    @IBAction func closeEditItemWindow(_ sender: NSButton) {
        self.view.window?.close()
    }
    
    @IBAction func saveSubjectAction(_ sender: Any) {
        let contents = (subjectContentsField.documentView as! NSTextView)
        let rtfContentsData = contents.rtf(from: NSRange(location: 0, length: contents.string.count))! as NSData
        let selectedTopic = parentTopicComboBox.objectValueOfSelectedItem as! String
        if let subjectToUpdate = subjectToEdit {
            subjectToUpdate.name = subjectNameField.stringValue
            subjectToUpdate.notes = subjectNotesField.stringValue
            subjectToUpdate.contents = rtfContentsData
            subjectToUpdate.lastReviewed = Date() as NSDate
            subjectToUpdate.parentTopic = TopicMO.fetchBy(name: selectedTopic)
            SubjectMO.update()
            NotificationCenter.default.post(name: .updatedSubject, object: subjectNameField.stringValue)
        } else {
            SubjectMO.save(name: subjectNameField.stringValue, contents: rtfContentsData, notes: subjectNotesField.stringValue, parentTopic: TopicMO.fetchBy(name: selectedTopic))
            NotificationCenter.default.post(name: .newSubject, object: subjectNameField.stringValue)
        }
        self.view.window?.close()
    }
}
