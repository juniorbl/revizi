//
//  ViewController.swift
//  ehnoze
//
//  Created by Carlos on 2018-11-17.
//  Copyright © 2018 Carlos Luz. All rights reserved.
//

import Cocoa

class MainWindowViewController: NSViewController {

    @IBOutlet weak var richText: NSScrollView!
    @IBOutlet weak var mainContentView: NSView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let item = Item(description: "testing", contents: Data(), lastReviewed: Date())
        richText.documentView?.insertText(item.load())
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func newItemBtnClicked(_ sender: Any) {
        print("New item clicked")
    }
    
    @IBAction func saveClicked(_ sender: Any) {
        let contents = (richText.documentView as! NSTextView)
        let rtfContents = contents.rtf(from: NSRange(location: 0, length: contents.string.count))
        let item = Item(description: "testing", contents: rtfContents ?? Data(), lastReviewed: Date())
        item.save()
    }
}
