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
    var contents: Data
    var lastReviewed: Date
    
    // move to file manager
    let userDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    func save() {
        let pathToFile = self.userDirectory.appendingPathComponent(description + ".rtf") // move to file manager
        do {
            try contents.write(to: pathToFile)
        } catch {
            print("Error: \(error)")
        }
    }
    
    func load() -> NSAttributedString {
        do {
            let pathToFile: URL = self.userDirectory.appendingPathComponent(description + ".rtf")
            return try NSAttributedString(url: pathToFile,
                                          options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf],
                                          documentAttributes: nil)
        } catch let error {
            print("Error \(error)")
        }
        return NSAttributedString()
    }
}
