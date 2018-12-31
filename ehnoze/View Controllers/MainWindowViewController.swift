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
    let editTopicController = "Edit Topic View Controller"
    var topics = [TopicMO]()
    var subjectBeingDisplayed: SubjectMO?
    var lastSelectedTopic: TopicMO?
    
    // Do any additional setup after loading the view.
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.onSubjectCreatedOrUpdated(notification:)), name: .newSubject, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onSubjectCreatedOrUpdated(notification:)), name: .updatedSubject, object: nil)
        reloadTopicsAndSubjectsDisplay()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func editItemAction(_ sender: NSButton) {
        if let subjectToEdit = subjectBeingDisplayed {
            let editSubjectWindowController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: self.editSubjectController) as! NSWindowController
            if let editSubjectWindow = editSubjectWindowController.window {
                let editSubjectController = editSubjectWindow.contentViewController as! EditSubjectViewController
                editSubjectController.subjectToEdit = subjectToEdit
                editSubjectWindowController.showWindow(editSubjectWindow)
            }
        } else {
            displayDialogWith(message: "No subject selected", informativeText: "You need to select a subject to edit") // TODO localize
        }
    }
    
    @IBAction func itemClicked(_ sender: NSOutlineView) {
        let selectedItem = sender.item(atRow: sender.clickedRow)
        if selectedItem is SubjectMO {
            let subjectName = (selectedItem as! SubjectMO).name ?? ""
            displaySubject(SubjectMO.fetchBy(name: subjectName)!)
        } else if selectedItem is TopicMO {
            lastSelectedTopic = selectedItem as? TopicMO
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
    
    @IBAction func editTopicAction(_ sender: Any?) {
        if let topicToEdit = lastSelectedTopic {
            let editTopicWindowController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: self.editTopicController) as! NSWindowController
            if let editTopicWindow = editTopicWindowController.window {
                let editTopicController = editTopicWindow.contentViewController as! EditTopicViewController
                editTopicController.topicToEdit = topicToEdit
                NSApplication.shared.runModal(for: editTopicWindow)
                editTopicWindowController.close()
                reloadTopicsAndSubjectsDisplay()
            }
        } else {
            displayDialogWith(message: "No topic selected", informativeText: "You need to select a topic to edit") // TODO localize
        }
    }
    
    @IBAction func deleteTopicAction(_ sender: Any?) {
        if let topicToEdit = lastSelectedTopic {
            let userAccepted = displayDialogOkCancel(question: "Are you sure you want to delete the topic '" + (lastSelectedTopic?.name)! + "' ?",
                                                     infoText: "All subjects in this topic will be deleted") // TODO localize
            if userAccepted {
                TopicMO.delete(id: topicToEdit.objectID)
                lastSelectedTopic = nil
                reloadTopicsAndSubjectsDisplay()
            }
        } else {
            displayDialogWith(message: "No topic selected", informativeText: "You need to select a topic to delete") // TODO localize
        }
    }
    
    @IBAction func newTopicAction(_ sender: Any?) {
        let editTopicController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: self.editTopicController) as! NSWindowController
        if let editTopicWindow = editTopicController.window {
            NSApplication.shared.runModal(for: editTopicWindow)
            editTopicWindow.close()
            reloadTopicsAndSubjectsDisplay()
        }
    }
    
    @IBAction func newSubjectAction(_ sender: Any?) {
        let editSubjectWindowController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: self.editSubjectController) as! NSWindowController
        if let editSubjectWindow = editSubjectWindowController.window {
            editSubjectWindowController.showWindow(editSubjectWindow)
        }
    }
    
    @IBAction func deleteSubjectAction(_ sender: Any?) {
        if let subjectToDelete = subjectBeingDisplayed {
            let userAccepted = displayDialogOkCancel(question: "Are you sure you want to delete the subject '" + (subjectBeingDisplayed?.name)! + "' ?") // TODO localize
            if userAccepted {
                SubjectMO.delete(id: subjectToDelete.objectID)
                subjectBeingDisplayed = nil
                clearSubjectFields()
                reloadTopicsAndSubjectsDisplay()
            }
        } else {
            displayDialogWith(message: "No subject selected", informativeText: "You need to select a subject to delete") // TODO localize
        }
    }
    
    // called when a notification is sent from another controller saying a new subject was created or updated
    // see viewDidLoad() where the notification is being configured
    @objc func onSubjectCreatedOrUpdated(notification: NSNotification) {
        let subjectName: String = notification.object as! String
        reloadTopicsAndSubjectsDisplay()
        let subjectCreatedOrUpdated: SubjectMO = SubjectMO.fetchBy(name: subjectName)!
        displaySubject(subjectCreatedOrUpdated)
        selectSubject(subjectCreatedOrUpdated)
    }
    
    fileprivate func selectSubject(_ subject: SubjectMO) {
        topicAndSubjectsDisplay.expandItem(subject.parentTopic)
        let subjectIndex = topicAndSubjectsDisplay.row(forItem: subject)
        topicAndSubjectsDisplay.selectRowIndexes(IndexSet(integer: subjectIndex), byExtendingSelection: false)
    }
    
    fileprivate func displaySubject(_ subjectToDisplay: SubjectMO) {
        subjectBeingDisplayed = subjectToDisplay
        subjectNameAndDescriptionLabel.stringValue = "\(subjectToDisplay.name ?? ""): \(subjectToDisplay.notes ?? "")"
        mainContentText.textStorage?.setAttributedString(subjectToDisplay.contentsAsString())
        topicDescriptionLabel.stringValue = subjectToDisplay.parentTopic?.name ?? ""
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
            createTopicColumn(tableColumn, &cellViewFromTopicListTable, outlineView, topic)
        } else if let subject = item as? SubjectMO {
            createSubjectColumn(tableColumn, &cellViewFromTopicListTable, outlineView, subject)
        }
        return cellViewFromTopicListTable
    }
    
    fileprivate func createTopicColumn(_ tableColumn: NSTableColumn?, _ cellViewFromTopicListTable: inout NSTableCellView?, _ outlineView: NSOutlineView, _ topic: TopicMO) {
        // TODO set topic backgound color to grey for topic
        if (tableColumn?.identifier)!.rawValue == "DateColumn" {
            // if it's a date colum, get the date cell to display the last reviewed date
            cellViewFromTopicListTable = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TopicDateCell"), owner: self) as? NSTableCellView
            if let textField = cellViewFromTopicListTable?.textField {
                textField.stringValue = String(topic.daysSinceLastSubjectReviewed) + " day(s) ago" // TODO: localize
                textField.sizeToFit()
            }
        } else {
            // if it's not a date colum, get the cell to display the topic name
            cellViewFromTopicListTable = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TopicCell"), owner: self) as? NSTableCellView
            if let textField = cellViewFromTopicListTable?.textField {
                textField.stringValue = topic.name ?? ""
                textField.sizeToFit()
            }
        }
    }
    
    fileprivate func createSubjectColumn(_ tableColumn: NSTableColumn?, _ cellViewFromTopicListTable: inout NSTableCellView?, _ outlineView: NSOutlineView, _ subject: SubjectMO) {
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
    static let updatedSubject = Notification.Name("updatedSubject")
}
