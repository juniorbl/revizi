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
    var subjectBeingDisplayed: SubjectMO?
    
    // Do any additional setup after loading the view.
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.selectSubjectNamed(notification:)), name: .newSubject, object: nil)
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
                editSubjectController.subjectToEdit = subjectToEdit
                NSApplication.shared.runModal(for: editSubjectWindow)
                editSubjectWindow.close()
                reloadTopicsAndSubjectsDisplay()
                displaySubject(subjectToEdit)
                selectSubject(subjectToEdit)
            }
        } else {
            displayDialogWith(message: "No subject selected", informativeText: "You need to select a subject to edit") // TODO localize
        }
    }
    
    @IBAction func itemClicked(_ sender: NSOutlineView) {
        let selectedSubject = sender.item(atRow: sender.clickedRow)
        if selectedSubject is SubjectMO {
            let subjectName = (selectedSubject as! SubjectMO).name ?? ""
            displaySubject(SubjectMO.fetchBy(name: subjectName))
        }
    }
    
    @IBAction func topicDoubleClicked(_ sender: NSOutlineView) {
        let itemClicked = sender.item(atRow: sender.clickedRow)
        if itemClicked is TopicMO {
            if sender.isItemExpanded(itemClicked) {
                sender.collapseItem(itemClicked)
            } else {
                sender.expandItem(itemClicked)
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
            selectSubject(subjectBeingDisplayed!)
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
    
    // called when a notification is sent from another controller saying a new subject was created
    // see viewDidLoad() where the notification is being configured
    @objc func selectSubjectNamed(notification: NSNotification) {
        let newlyCreatedSubjectName: String = notification.object as! String
        reloadTopicsAndSubjectsDisplay()
        displaySubject(SubjectMO.fetchBy(name: newlyCreatedSubjectName))
    }
    
    fileprivate func selectSubject(_ subject: SubjectMO) {
        topicAndSubjectsDisplay.expandItem(subject.parentTopic)
        let subjectIndex = topicAndSubjectsDisplay.row(forItem: subject)
        topicAndSubjectsDisplay.selectRowIndexes(IndexSet(integer: subjectIndex), byExtendingSelection: false)
    }
    
    fileprivate func displaySubject(_ subjectToDisplay: SubjectMO) {
        subjectBeingDisplayed = subjectToDisplay
        let subjectNotes = subjectToDisplay.notes ?? ""
        subjectNameAndDescriptionLabel.stringValue = subjectToDisplay.name ?? "" + ": " + subjectNotes
        mainContentText.textStorage?.setAttributedString(subjectToDisplay.contentsAsString())
        topicDescriptionLabel.stringValue = subjectToDisplay.parentTopic?.name ?? ""
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
    
    // tell which items can be collapsed or expanded
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

extension Notification.Name {
    static let newSubject = Notification.Name("newSubject")
}
