//
//  SubjectMO.swift
//  ehnoze
//
//  Created by Carlos on 2018-12-01.
//  Copyright © 2018 Carlos Luz. All rights reserved.
//

import CoreData
import Foundation

// Represents a subject of study, its instances are persisted using Core Data
class SubjectMO: NSManagedObject {
    @NSManaged var name: String
}
