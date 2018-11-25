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
    @IBOutlet weak var topicDescriptionLabel: NSTextField!
    @IBOutlet weak var itemNameAndDescriptionLabel: NSTextField!
    
    var topics = Topic.topicList()
    let dateFormatter = DateFormatter()
    var selectedItem = Item()
    // tree example: - NSOutlineView - https://www.youtube.com/watch?v=_SvZiUF-ShM
    // https://www.raywenderlich.com/1201-nsoutlineview-on-macos-tutorial
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        selectedItem = Item(name: "testing")
        mainContent.documentView?.insertText(Item.load(name: selectedItem.name).contents)
        
        dateFormatter.dateStyle = .short
        // dateFormatter.string(from: something)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func newItemBtnClicked(_ sender: Any) {
        print("New item clicked")
    }
    
    @IBAction func itemClicked(_ sender: NSOutlineView) {
        let clickedItem = sender.item(atRow: sender.clickedRow)
        if clickedItem is Item {
            selectedItem = Item(name: (clickedItem as! Item).name, contents: NSAttributedString(), lastReviewed: Date())
            let itemContents = (mainContent.documentView as! NSTextView)
            let loadedItem = Item.load(name: selectedItem.name)
            itemContents.insertText(loadedItem.contents, replacementRange: NSRange(location: 0, length: itemContents.string.count))
            let loadedItemName = loadedItem.name
            let loadedItemDescription = loadedItem.description ?? ""
            itemNameAndDescriptionLabel.stringValue = loadedItemName + ": " + loadedItemDescription
            if let parentTopic = sender.parent(forItem: clickedItem) as? Topic {
                topicDescriptionLabel.stringValue = parentTopic.name
            }
            
        }
    }
    
    @IBAction func saveContentsAction(_ sender: Any) {
        let contents = (mainContent.documentView as! NSTextView)
        let rtfContentsData = contents.rtf(from: NSRange(location: 0, length: contents.string.count))
        let rtfContents = NSAttributedString(rtf: rtfContentsData ?? Data(), documentAttributes: nil)
        let item = Item(name: selectedItem.name, contents: rtfContents ?? NSAttributedString(), lastReviewed: Date())
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
                    textField.stringValue = String(item.numberOfDaysSinceLastReviewed()) + " day(s) ago" // TODO: localize
                    textField.sizeToFit()
                }
            } else {
                // if it's not a date colum, get the cell to display the item name
                cellViewFromTopicListTable = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ItemCell"), owner: self) as? NSTableCellView
                if let textField = cellViewFromTopicListTable?.textField {
                    textField.stringValue = item.name
                    textField.sizeToFit()
                }
            }
            // change color based on how old the last review is
            if let textField = cellViewFromTopicListTable?.textField {
                textField.textColor = getTextColour(numberOfDaysSinceLastReviewed: item.numberOfDaysSinceLastReviewed())
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
