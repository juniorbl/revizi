//
//  TopicMO+CoreDataClass.swift
//  ehnoze
//
//  Created by Carlos on 2018-12-01.
//  Copyright © 2018 Carlos Luz. All rights reserved.
//
//

import Foundation
import CoreData

@objc(TopicMO)
public class TopicMO: NSManagedObject {
    static private var repository: DataRepository = DataRepository()
    
    var daysSinceLastSubjectReviewed: Int {
        get {
            return numberOfDaysSinceLastSubjectReviewed()
        }
    }
    
    static func fetchBy(name: String) -> TopicMO {
        let fetchByNameRequest: NSFetchRequest<TopicMO> = self.fetchRequest()
        fetchByNameRequest.predicate = NSPredicate(format: "name == %@", name)
        do {
            let result = try repository.managedContext.fetch(fetchByNameRequest)
            return result[0]
        } catch let error as NSError {
            print("Error while fetching Topic: \(error)")
            return TopicMO()
        }
    }
    
    static func fetchAll() -> [TopicMO] {
        do {
            var allTopics = try repository.managedContext.fetch(TopicMO.fetchRequest()) as! [TopicMO]
            allTopics.sort(by: { $0.daysSinceLastSubjectReviewed > $1.daysSinceLastSubjectReviewed })
            return allTopics
        } catch {
            print("Error while fetching Topic: \(error)")
            return [TopicMO]()
        }
    }
    
    static func save(name: String, notes: NSData = NSData()) {
        let entity = NSEntityDescription.entity(forEntityName: "Topic", in: repository.managedContext)!
        let newTopic = NSManagedObject(entity: entity, insertInto: repository.managedContext)
        newTopic.setValue(name, forKey: "name")
        do {
            try repository.managedContext.save()
        } catch let error as NSError {
            print("Error while saving Topic: \(error)")
        }
    }
    
    private func numberOfDaysSinceLastSubjectReviewed() -> Int {
        var lastReviwedSubject: Int = Int.max
        for subject in subjects ?? NSOrderedSet() {
            let currentSubject = subject as! SubjectMO
            let subjectLastReviwedDays = currentSubject.numberOfDaysSinceLastReviewed()
            if subjectLastReviwedDays < lastReviwedSubject {
                lastReviwedSubject = subjectLastReviwedDays
            }
        }
        return lastReviwedSubject
    }
}

extension TopicMO {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TopicMO> {
        return NSFetchRequest<TopicMO>(entityName: "Topic")
    }
    
    @NSManaged public var name: String?
    @NSManaged public var notes: NSData?
    @NSManaged public var subjects: NSOrderedSet?
}

extension TopicMO {
   @objc(addSubjectsObject:)
   @NSManaged public func addToSubjects(_ value: SubjectMO)
    
   @objc(removeSubjectsObject:)
   @NSManaged public func removeFromSubjects(_ value: SubjectMO)
    
    @objc(addSubjects:)
    @NSManaged public func addToSubjects(_ values: NSSet)
    
    @objc(removeSubjects:)
    @NSManaged public func removeFromSubjects(_ values: NSSet)
}
