//
//  SubjectMO+CoreDataClass.swift
//  ehnoze
//
//  Created by Carlos on 2018-12-03.
//  Copyright © 2018 Carlos Luz. All rights reserved.
//
//

import Foundation
import CoreData

@objc(SubjectMO)
public class SubjectMO: NSManagedObject {
    static private var repository: DataRepository = DataRepository()
    
    static func fetchBy(name: String) -> SubjectMO {
        let fetchByNameRequest: NSFetchRequest<SubjectMO> = self.fetchRequest()
        fetchByNameRequest.predicate = NSPredicate(format: "name == %@", name)
        do {
            let result = try repository.managedContext.fetch(fetchByNameRequest)
            return result[0]
        } catch let error as NSError {
            print("Error while fetching Subject: \(error)")
            return SubjectMO()
        }
    }
    
    static func save(name: String, contents: NSData, notes: String = "", parentTopic: TopicMO) {
        let entity = NSEntityDescription.entity(forEntityName: "Subject", in: repository.managedContext)!
        let newSubject = NSManagedObject(entity: entity, insertInto: repository.managedContext)
        newSubject.setValue(name, forKey: "name")
        newSubject.setValue(contents, forKey: "contents")
        newSubject.setValue(notes, forKey: "notes")
        newSubject.setValue(Date(), forKey: "lastReviewed")
        newSubject.setValue(parentTopic, forKey: "parentTopic")
        do {
            try repository.managedContext.save()
        } catch let error as NSError {
            print("Error while saving Subject: \(error)")
        }
    }
    
    func numberOfDaysSinceLastReviewed() -> Int {
//        return Calendar.current.dateComponents([.day], from: self.lastReviewed, to: Date()).day ?? 0
        return 2 // TEMP
    }
}

extension SubjectMO {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SubjectMO> {
        return NSFetchRequest<SubjectMO>(entityName: "Subject")
    }
    
    @NSManaged public var lastReviewed: NSDate?
    @NSManaged public var notes: String?
    @NSManaged public var name: String?
    @NSManaged public var contents: NSData?
    @NSManaged public var parentTopic: TopicMO?
}
