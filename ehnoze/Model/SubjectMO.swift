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
    
    static func update() {
        do {
            // this assumes that an instance of SubjectMO is already loaded in memory and just call the context to save,
            // maybe theres's a better way to do this
            try repository.managedContext.save()
        } catch let error as NSError {
            print("Error while updating Subject: \(error)")
        }
    }
    
    static func delete(subjectId: NSManagedObjectID) {
        do {
            let subjectToDelete = fetchBy(id: subjectId)
            repository.managedContext.delete(subjectToDelete)
            try repository.managedContext.save()
        } catch let error as NSError {
            print("Error while deleting Subject: \(error)")
        }
    }
    
    static private func fetchBy(id: NSManagedObjectID) -> SubjectMO {
        do {
            let loadedSubject = try repository.managedContext.existingObject(with: id) as! SubjectMO
            return loadedSubject
        } catch let error as NSError {
            print("Error while fetching Subject: \(error)")
            return SubjectMO()
        }
    }
    
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
    
    func numberOfDaysSinceLastReviewed() -> Int {
        return Calendar.current.dateComponents([.day], from: self.lastReviewed! as Date, to: Date()).day ?? 0
    }
    
    func contentsAsString() -> NSAttributedString {
        let loadSubjectOptions = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf]
        do {
            return try NSAttributedString(data: self.contents! as Data, options: loadSubjectOptions, documentAttributes: nil)
        } catch let error as NSError {
            print("Error while accessing contents of Subject: \(error)")
            return NSAttributedString()
        }
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
