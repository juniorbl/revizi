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
    
    // tree example: - NSOutlineView - https://www.youtube.com/watch?v=_SvZiUF-ShM
    // https://www.raywenderlich.com/1201-nsoutlineview-on-macos-tutorial
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let item = Item(description: "testing", contents: NSAttributedString(), lastReviewed: Date())
        mainContent.documentView?.insertText(item.load().contents)
        
        let savedFiles = Item.retrieveAll()
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
