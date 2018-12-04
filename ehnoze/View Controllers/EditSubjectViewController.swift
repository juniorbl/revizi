//
//  EditItemSubjectController.swift
//  ehnoze
//
//  Created by Carlos on 2018-11-27.
//  Copyright © 2018 Carlos Luz. All rights reserved.
//

import Cocoa

class EditSubjectViewController: NSViewController {
    
//    @objc dynamic var itemName = String()
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
    
    @IBAction func closeEditItemWindow(_ sender: NSButton) {
        NSApplication.shared.stopModal()
    }
    
    @IBAction func saveSubectAction(_ sender: Any) {
        let contents = (subjectContentsField.documentView as! NSTextView)
        let rtfContentsData = contents.rtf(from: NSRange(location: 0, length: contents.string.count))! as NSData
        let selectedTopic = parentTopicComboBox.objectValueOfSelectedItem as! String
        SubjectMO.save(name: subjectNameField.stringValue, contents: rtfContentsData, notes: subjectNotesField.stringValue, parentTopic: TopicMO.fetchBy(name: selectedTopic))
        NSApplication.shared.stopModal()
    }
}
