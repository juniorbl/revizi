//
//  TopicMO.swift
//  revizi
//
//  Created by Carlos Luz on 2018-12-01.
//

import Foundation
import CoreData
import os

@objc(TopicMO)
public class TopicMO: NSManagedObject {
    
    static func fetchBy(name: String) -> TopicMO? {
        let fetchByNameRequest: NSFetchRequest<TopicMO> = self.fetchRequest()
        fetchByNameRequest.predicate = NSPredicate(format: "name ==[c] %@", name)
        do {
            let result = try repository.managedContext.fetch(fetchByNameRequest)
            if result.isEmpty {
                return nil
            }
            return result[0]
        } catch let error as NSError {
            os_log("Error while fetching Topic: %s", error)
            return TopicMO()
        }
    }
    
    static func fetchAll() -> [TopicMO] {
        do {
            var allTopics = try repository.managedContext.fetch(TopicMO.fetchRequest()) as! [TopicMO]
            allTopics.sort(by: { $0.daysSinceLastSubjectReviewed > $1.daysSinceLastSubjectReviewed })
            // NSOrderedSet doesn't seem to have a way to order by an object property,
            // and I couldn't find a way to sort during the fetch, so the subjects will be sorted here
            for topic in allTopics {
                let sortedSubjects = (topic.subjects?.array as! [SubjectMO]).sorted(by: { $0.sinceLastReviewedIn(.hour) > $1.sinceLastReviewedIn(.hour) })
                topic.subjects = NSOrderedSet(array: sortedSubjects)
            }
            return allTopics
        } catch let error as NSError {
            os_log("Error while fetching Topic: %s", error)
            return [TopicMO]()
        }
    }
    
    func fetchOldestSubjectInTopic() -> SubjectMO? {
        if subjects?.count ?? 0 > 0 {
            return (self.subjects?.array as! [SubjectMO]).sorted(by: { $0.sinceLastReviewedIn(.hour) > $1.sinceLastReviewedIn(.hour) }).first!
        }
        return nil
    }
    
    static func save(name: String, notes: NSData = NSData()) {
        let entity = NSEntityDescription.entity(forEntityName: "Topic", in: repository.managedContext)!
        let newTopic = NSManagedObject(entity: entity, insertInto: repository.managedContext)
        newTopic.setValue(name, forKey: "name")
        newTopic.setValue(notes, forKey: "notes")
        do {
            try repository.managedContext.save()
        } catch let error as NSError {
            os_log("Error while saving Topic: %s", error)
        }
    }
    
    static func validateCreate(_ topicName: String) -> String? {
        return validateCreate(topicName, "topic name", validationFunction: TopicMO.fetchBy(name:), forElementName: "topic")
    }
    
    static func validateUpdate(newTopicName: String, originalTopicName: String) -> String? {
        return validateUpdate(newTopicName, originalTopicName, "topic name", validationFunction: TopicMO.fetchBy(name:), forElementName: "topic")
    }
    
    private func numberOfDaysSinceLastSubjectReviewed() -> Int {
        var lastReviwedSubject: Int = Int.max
        for subject in subjects ?? NSOrderedSet() {
            let currentSubject = subject as! SubjectMO
            let subjectLastReviwedDays = currentSubject.sinceLastReviewedIn(.day)
            if subjectLastReviwedDays < lastReviwedSubject {
                lastReviwedSubject = subjectLastReviwedDays
            }
        }
        return lastReviwedSubject == Int.max ? 0 : lastReviwedSubject
    }
    
    var daysSinceLastSubjectReviewed: Int {
        get {
            return numberOfDaysSinceLastSubjectReviewed()
        }
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
