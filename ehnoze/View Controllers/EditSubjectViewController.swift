//
//  EditItemSubjectController.swift
//  ehnoze
//
//  Created by Carlos on 2018-11-27.
//  Copyright © 2018 Carlos Luz. All rights reserved.
//

import Cocoa

class EditSubjectViewController: NSViewController {
    
    @objc dynamic var itemName = String()
    @IBOutlet weak var itemContents: NSScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func closeEditItemWindow(_ sender: NSButton) {
        NSApplication.shared.stopModal()
    }
    
    @IBAction func saveContentsAction(_ sender: Any) {
        let contents = (itemContents.documentView as! NSTextView)
        let rtfContentsData = contents.rtf(from: NSRange(location: 0, length: contents.string.count))! as NSData
        SubjectMO.save(name: "testing 5", contents: rtfContentsData, parentTopic: TopicMO.fetchAll()[2])
        NSApplication.shared.stopModal()
    }
}
