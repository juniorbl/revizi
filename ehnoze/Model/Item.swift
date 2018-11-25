//
//  Item.swift
//  ehnoze
//
//  Created by Carlos on 2018-11-22.
//  Copyright © 2018 Carlos Luz. All rights reserved.
//

import Foundation

struct Item {
    var description: String
    var contents: NSAttributedString
    var lastReviewed: Date
    
    init() {
        self.description = ""
        self.contents = NSAttributedString()
        self.lastReviewed = Date()
    }
    
    init(description: String) {
        self.description = description
        self.contents = NSAttributedString()
        self.lastReviewed = Date()
    }

    init(description: String, contents: NSAttributedString, lastReviewed: Date) {
        self.description = description
        self.contents = contents
        self.lastReviewed = lastReviewed
    }
    
    func save() {
        let userDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let pathToFile = userDirectory.appendingPathComponent(description + ".rtf") // move to file manager
        let writeDocumentAttributes = [NSAttributedString.DocumentAttributeKey.documentType: NSAttributedString.DocumentType.rtf]
        do {
            try contents.data(from: NSRange(location: 0, length: contents.length), documentAttributes: writeDocumentAttributes)
                .write(to: pathToFile)
        } catch {
            print("Error: \(error)")
        }
    }
    
    func numberOfDaysSinceLastReviewed() -> Int {
        return Calendar.current.dateComponents([.day], from: self.lastReviewed, to: Date()).day ?? 0
    }
    
    static func load(description: String) -> Item {
        do {
            let userDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let pathToFile: URL = userDirectory.appendingPathComponent(description + ".rtf")
            let loadDocumentOptions = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf]
            let loadedContents = try NSAttributedString(url: pathToFile, options: loadDocumentOptions, documentAttributes: nil)
            return Item(description: description, contents: loadedContents, lastReviewed: Date())
        } catch let error {
            print("Error \(error)")
        }
        return Item(description: "", contents: NSAttributedString(), lastReviewed: Date())
    }
    
    static func listAll() -> [String : Item] {
        let userDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] // TODO: move to file manager
        var listItems: [String : Item] = [:]
        do {
            let savedFiles = try FileManager.default.contentsOfDirectory(at: userDirectory, includingPropertiesForKeys: [], options: .skipsHiddenFiles)
                .filter{ $0.pathExtension == "rtf" }
            for filePath in savedFiles {
                let filename = (filePath.lastPathComponent as NSString).deletingPathExtension
                let someDateExample = Date().addingTimeInterval(TimeInterval(exactly: -Int.random(in: 0 ..< 30)*24*60*60)!)
                listItems[filename] = Item(description: filename, contents: NSAttributedString(), lastReviewed: someDateExample)
//                .sorted(by: <#T##((key: String, value: Item), (key: String, value: Item)) throws -> Bool#>)
                // TODO: get the stored date
            }
        } catch let error {
            print("Error \(error)")
        }
        return listItems
    }
}
