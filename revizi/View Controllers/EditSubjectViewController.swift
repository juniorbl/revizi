//
//  EditItemSubjectController.swift
//  revizi
//
//  Created by Carlos Luz on 2018-11-27.
//

import Cocoa

class EditSubjectViewController: NSViewController {
    
    @IBOutlet weak var parentTopicComboBox: NSComboBox!
    @IBOutlet weak var subjectNotesField: NSScrollView!
    @IBOutlet weak var subjectContentsField: NSScrollView!
    @IBOutlet weak var subjectNameField: NSTextField!

    var subjectToEdit: SubjectMO? {
        didSet { // called every time subjectToEdit changes
            loadSubjectToEdit()
        }
    }
    
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
                subjectNameField.stringValue = subject.name ?? "No subject name"
                parentTopicComboBox.selectItem(withObjectValue: subject.parentTopic?.name)
                if let subjectNotesData = subject.notes {
                    subjectNotesField.documentView?.insertText(subjectNotesData)
                }
                subjectContentsField.documentView?.insertText(subject.contentsAsString())
            }
        }
    }
    
    @IBAction func closeEditItemWindow(_ sender: NSButton) {
        self.view.window?.close()
    }
    
    @IBAction func saveSubjectAction(_ sender: Any) {
        if parentTopicComboBox.indexOfSelectedItem == -1 {
            displayDialogWith(message: "The subject must have a topic")
            return
        }
        let contents = (subjectContentsField.documentView as! NSTextView)
        let rtfContentsData = contents.rtf(from: NSRange(location: 0, length: contents.string.count))! as NSData
        let notesContents = (subjectNotesField.documentView as! NSTextView)
        let selectedTopic = parentTopicComboBox.objectValueOfSelectedItem as! String
        if let subjectToUpdate = subjectToEdit {
            if displayErrorMessageIfInvalid({ SubjectMO.validateUpdate(newSubjectName: subjectNameField.stringValue, originalSubjectName: subjectToEdit?.name ?? "") }) {
                return
            }
            subjectToUpdate.name = subjectNameField.stringValue
            subjectToUpdate.notes = notesContents.string
            subjectToUpdate.contents = rtfContentsData
            subjectToUpdate.lastReviewed = Date() as NSDate
            subjectToUpdate.parentTopic = TopicMO.fetchBy(name: selectedTopic)
            SubjectMO.update()
            NotificationCenter.default.post(name: .updatedSubject, object: subjectNameField.stringValue)
        } else {
            if displayErrorMessageIfInvalid({ SubjectMO.validateCreate(subjectNameField.stringValue) }) {
                return
            }
            SubjectMO.save(name: subjectNameField.stringValue, contents: rtfContentsData, notes: notesContents.string, parentTopic: TopicMO.fetchBy(name: selectedTopic)!)
            NotificationCenter.default.post(name: .newSubject, object: subjectNameField.stringValue)
        }
        self.view.window?.close()
    }
}
