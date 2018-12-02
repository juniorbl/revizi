//
//  DataRepository.swift
//  ehnoze
//
//  Created by Carlos on 2018-12-02.
//  Copyright © 2018 Carlos Luz. All rights reserved.
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
