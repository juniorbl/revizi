//
//  ViewController.swift
//  ehnoze
//
//  Created by Carlos on 2018-11-17.
//  Copyright © 2018 Carlos Luz. All rights reserved.
//

import Cocoa

class MainWindowViewController: NSViewController {

    @IBOutlet weak var topicDescriptionLabel: NSTextField!
    @IBOutlet weak var subjectNameAndDescriptionLabel: NSTextField!
    @IBOutlet var mainContentText: NSTextView!
    @IBOutlet weak var topicAndSubjectsDisplay: NSOutlineView!
    
    let editSubjectController = "Edit Subject View Controller"
    
    var topics = TopicMO.fetchAll()
//    let dateFormatter = DateFormatter()
    var subjectBeingDisplayed: SubjectMO?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        selectedItem = Item(name: "testing")
//        mainContentText.textStorage?.setAttributedString(Item.load(name: selectedItem.name).contents)
//
//        dateFormatter.dateStyle = .short
        // dateFormatter.string(from: something)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func editItemAction(_ sender: NSButton) {
        if let subjectToEdit = subjectBeingDisplayed {
            let editSubjectController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: self.editSubjectController) as! NSWindowController
            if let editSubjectWindow = editSubjectController.window {
                let editSubjectController = editSubjectWindow.contentViewController as! EditSubjectViewController
    //            let selectedSubject = topicAndSubjectsDisplay.item(atRow: topicAndSubjectsDisplay.selectedRow) as! SubjectMO
                editSubjectController.subjectToEdit = subjectToEdit
                NSApplication.shared.runModal(for: editSubjectWindow)
                editSubjectWindow.close()
                reloadTopicsAndSubjectsDisplay()
                
                let updatedSubjectIndex = topicAndSubjectsDisplay.row(forItem: subjectToEdit)
                topicAndSubjectsDisplay.selectRowIndexes(IndexSet(integer: updatedSubjectIndex), byExtendingSelection: false)
                let subjectNotes = subjectToEdit.notes ?? ""
                subjectNameAndDescriptionLabel.stringValue = subjectToEdit.name ?? "" + ": " + subjectNotes
                mainContentText.textStorage?.setAttributedString(subjectToEdit.contentsAsString() )
            }
        } else {
            displayDialogWith(message: "No subject selected", informativeText: "You need to select a subject to edit") // TODO localize
        }
    }
    
    @IBAction func itemClicked(_ sender: NSOutlineView) {
        let selectedSubject = sender.item(atRow: sender.clickedRow)
        if selectedSubject is SubjectMO {
            let subjectName = (selectedSubject as! SubjectMO).name ?? ""
            let loadedSubject = SubjectMO.fetchBy(name: subjectName)
            subjectBeingDisplayed = loadedSubject
            mainContentText.textStorage?.setAttributedString(loadedSubject.contentsAsString())
            let subjectNotes = loadedSubject.notes ?? ""
            subjectNameAndDescriptionLabel.stringValue = loadedSubject.name ?? "" + ": " + subjectNotes
            if let parentTopic = sender.parent(forItem: selectedSubject) as? TopicMO {
                topicDescriptionLabel.stringValue = parentTopic.name ?? ""
            }
        }
    }
    
    @IBAction func newTopicAction(_ sender: Any?) {
        let editTopicController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "Edit Topic View Controller") as! NSWindowController
        if let editTopicWindow = editTopicController.window {
            NSApplication.shared.runModal(for: editTopicWindow)
            editTopicWindow.close()
            reloadTopicsAndSubjectsDisplay()
        }
    }
    
    @IBAction func newSubjectAction(_ sender: Any?) {
        let editSubjectController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: self.editSubjectController) as! NSWindowController
        if let editSubjectWindow = editSubjectController.window {
            NSApplication.shared.runModal(for: editSubjectWindow)
            editSubjectWindow.close()
            reloadTopicsAndSubjectsDisplay()
            // TODO select the newly added subject, maybe sort the list by last time reviewed, the new one would be the last element
        }
    }
    
    @IBAction func deleteSubjectAction(_ sender: Any?) {
        if let subjectToDelete = subjectBeingDisplayed {
            let userAccepted = displayDialogOkCancel(question: "Are you sure you want to delete the subject '" + (subjectBeingDisplayed?.name)! + "' ?") // TODO localize
            if userAccepted {
                SubjectMO.delete(subjectId: subjectToDelete.objectID)
                subjectBeingDisplayed = nil
                clearSubjectFields()
                reloadTopicsAndSubjectsDisplay()
            }
        } else {
            displayDialogWith(message: "No subject selected", informativeText: "You need to select a subject to delete") // TODO localize
        }
    }
    
    fileprivate func displayDialogWith(message: String, informativeText: String = "") {
        let alert = NSAlert.init()
        alert.messageText = message
        alert.informativeText = informativeText
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK") // TODO localize
        alert.runModal()
    }
    
    fileprivate func displayDialogOkCancel(question: String) -> Bool {
        let alert = NSAlert.init()
        alert.messageText = question
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK") // TODO localize
        alert.addButton(withTitle: "Cancel") // TODO localize
        return alert.runModal() == .alertFirstButtonReturn
    }
    
    fileprivate func clearSubjectFields() {
        topicDescriptionLabel.stringValue = ""
        subjectNameAndDescriptionLabel.stringValue = ""
        mainContentText.textStorage?.setAttributedString(NSAttributedString())
    }
    
    fileprivate func reloadTopicsAndSubjectsDisplay() {
        topics = TopicMO.fetchAll()
        topicAndSubjectsDisplay.reloadData()
    }
}

// make the view controller the data source of the topic list
extension MainWindowViewController: NSOutlineViewDataSource {
    // the outline view needs to know how many items it should show
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let topic = item as? TopicMO {
            return topic.subjects?.count ?? 0
        }
        return topics.count
    }
    
    // the outline view needs to know which child it should show for a given parent and index
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let topic = item as? TopicMO {
            return topic.subjects?.array[index] ?? ""
        }
        return topics[index]
    }
    
    // tell it which items can be collapsed or expanded
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let topic = item as? TopicMO {
            return topic.subjects?.count ?? 0 > 0
        }
        return false
    }
}

// the topic list asks its delegate for the view it should show for a specific entry
extension MainWindowViewController: NSOutlineViewDelegate {
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        var cellViewFromTopicListTable: NSTableCellView?
        if let topic = item as? TopicMO {
            if (tableColumn?.identifier)!.rawValue == "DateColumn" {
                // if it's a date colum, get the date cell to display the last reviewed date
                cellViewFromTopicListTable = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TopicDateCell"), owner: self) as? NSTableCellView
                if let textField = cellViewFromTopicListTable?.textField {
                    textField.stringValue = String(topic.daysSinceLastSubjectReviewed) + " day(s) ago" // TODO: localize
                    textField.sizeToFit()
                }
            } else {
                cellViewFromTopicListTable = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TopicCell"), owner: self) as? NSTableCellView
                if let textField = cellViewFromTopicListTable?.textField {
                    textField.stringValue = topic.name ?? ""
                    textField.sizeToFit()
                }
            }
            // TODO set topic backgound color to grey
        } else if let subject = item as? SubjectMO {
            // create the columns for the subject information
            if (tableColumn?.identifier)!.rawValue == "DateColumn" {
                // if it's a date colum, get the date cell to display the last reviewed date
                cellViewFromTopicListTable = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "SubjectDateCell"), owner: self) as? NSTableCellView
                if let textField = cellViewFromTopicListTable?.textField {
                    textField.stringValue = String(subject.numberOfDaysSinceLastReviewed()) + " day(s) ago" // TODO: localize
                    textField.sizeToFit()
                }
            } else {
                // if it's not a date colum, get the cell to display the subject name
                cellViewFromTopicListTable = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "SubjectCell"), owner: self) as? NSTableCellView
                if let textField = cellViewFromTopicListTable?.textField {
                    textField.stringValue = subject.name ?? ""
                    textField.sizeToFit()
                }
            }
            // change color based on how old the last review is
            if let textField = cellViewFromTopicListTable?.textField {
                textField.textColor = getTextColour(numberOfDaysSinceLastReviewed: subject.numberOfDaysSinceLastReviewed())
            }
        }
        return cellViewFromTopicListTable
    }
    
    func getTextColour(numberOfDaysSinceLastReviewed: Int) -> NSColor {
        switch numberOfDaysSinceLastReviewed {
        // TODO: get values from preferences
        case 10...20:
            return NSColor.orange
        case 20...Int.max:
            return NSColor.red
        default:
            return NSColor.black
        }
    }
}
