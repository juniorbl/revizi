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
    
    // move to file manager
    let userDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    func save() {
        let pathToFile = self.userDirectory.appendingPathComponent(description + ".rtf") // move to file manager
        let writeDocumentAttributes = [NSAttributedString.DocumentAttributeKey.documentType: NSAttributedString.DocumentType.rtf]
        do {
            try contents.data(from: NSRange(location: 0, length: contents.length), documentAttributes: writeDocumentAttributes)
                .write(to: pathToFile)
        } catch {
            print("Error: \(error)")
        }
    }
    
    func load() -> Item {
        do {
            let pathToFile: URL = self.userDirectory.appendingPathComponent(description + ".rtf")
            let loadDocumentOptions = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf]
            let loadedContents = try NSAttributedString(url: pathToFile, options: loadDocumentOptions, documentAttributes: nil)
            return Item(description: "", contents: loadedContents, lastReviewed: Date())
        } catch let error {
            print("Error \(error)")
        }
        return Item(description: "", contents: NSAttributedString(), lastReviewed: Date())
    }
}
