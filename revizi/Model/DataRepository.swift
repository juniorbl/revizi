//
//  DataRepository.swift
//  revizi
//
//  Created by Carlos Luz on 2018-12-02.
//

import Foundation
import CoreData
import Cocoa

struct DataRepository {
    lazy var managedContext: NSManagedObjectContext = {
        let appDelegate = NSApp.delegate as? AppDelegate
        return (appDelegate?.persistentContainer.viewContext)!
    }()
}
