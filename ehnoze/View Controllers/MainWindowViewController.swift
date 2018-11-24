//
//  ViewController.swift
//  ehnoze
//
//  Created by Carlos on 2018-11-17.
//  Copyright © 2018 Carlos Luz. All rights reserved.
//

import Cocoa

class MainWindowViewController: NSViewController {

    @IBOutlet weak var mainContent: NSScrollView!
    @IBOutlet weak var mainContentView: NSView!
    
    var topics = Topic.topicList()
    let dateFormatter = DateFormatter()
    // tree example: - NSOutlineView - https://www.youtube.com/watch?v=_SvZiUF-ShM
    // https://www.raywenderlich.com/1201-nsoutlineview-on-macos-tutorial
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let item = Item(description: "testing", contents: NSAttributedString(), lastReviewed: Date())
        mainContent.documentView?.insertText(item.load().contents)
        
        dateFormatter.dateStyle = .short
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func newItemBtnClicked(_ sender: Any) {
        print("New item clicked")
    }
    
    @IBAction func saveContentsAction(_ sender: Any) {
        let contents = (mainContent.documentView as! NSTextView)
        let rtfContentsData = contents.rtf(from: NSRange(location: 0, length: contents.string.count))
        let rtfContents = NSAttributedString(rtf: rtfContentsData ?? Data(), documentAttributes: nil)
        let item = Item(description: "testing", contents: rtfContents ?? NSAttributedString(), lastReviewed: Date())
        item.save()
    }
}

// make the view controller the data source of the topic list
extension MainWindowViewController: NSOutlineViewDataSource {
    // the outline view needs to know how many items it should show
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let topic = item as? Topic {
            return topic.items.count
        }
        return topics.count
    }
    
    // the outline view needs to know which child it should show for a given parent and index
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let topic = item as? Topic {
            return topic.items[index]
        }
        return topics[index]
    }
    
    // tell it which items can be collapsed or expanded
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let topic = item as? Topic {
            return topic.items.count > 0
        }
        return false
    }
}

// the topic list asks its delegate for the view it should show for a specific entry
extension MainWindowViewController: NSOutlineViewDelegate {
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        var cellViewFromTopicListTable: NSTableCellView?
        if let topic = item as? Topic {
            cellViewFromTopicListTable = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TopicCell"), owner: self) as? NSTableCellView
            if let textField = cellViewFromTopicListTable?.textField {
                textField.stringValue = topic.name
                textField.sizeToFit()
            }
        } else if let item = item as? Item {
            // create the columns for the item information
            if (tableColumn?.identifier)!.rawValue == "DateColumn" {
                // if it's a date colum, get the date cell to display the last reviewed date
                cellViewFromTopicListTable = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DateCell"), owner: self) as? NSTableCellView
                if let textField = cellViewFromTopicListTable?.textField {
                    textField.stringValue = dateFormatter.string(from: item.lastReviewed)
                    textField.sizeToFit()
                }
            } else {
                // if it's not a date colum, get the cell to display the item description
                cellViewFromTopicListTable = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ItemCell"), owner: self) as? NSTableCellView
                if let textField = cellViewFromTopicListTable?.textField {
                    textField.stringValue = item.description
                    textField.sizeToFit()
                }
            }
        }
        return cellViewFromTopicListTable
    }
}