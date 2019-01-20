//
//  SubjectMO.swift
//  revizi
//
//  Created by Carlos on 2018-12-03.
//  Copyright © 2018 Carlos Luz. All rights reserved.
//
//

import Foundation
import CoreData

@objc(SubjectMO)
public class SubjectMO: NSManagedObject {
    var timerToMarkAsReviewed: Timer?
    var preferences = Preferences()
    
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
    
    static func validateCreate(_ subjectName: String) -> String? {
        return validateCreate(subjectName, "subject name", validationFunction: SubjectMO.fetchBy(name:), forElementName: "subject")
    }
    
    static func validateUpdate(newSubjectName: String, originalSubjectName: String) -> String? {
        return validateUpdate(newSubjectName, originalSubjectName, "subject name", validationFunction: SubjectMO.fetchBy(name:), forElementName: "subject")
    }
    
    static func fetchBy(name: String) -> SubjectMO? {
        let fetchByNameRequest: NSFetchRequest<SubjectMO> = self.fetchRequest()
        fetchByNameRequest.predicate = NSPredicate(format: "name ==[c] %@", name)
        do {
            let result = try repository.managedContext.fetch(fetchByNameRequest)
            if result.isEmpty {
                return nil
            }
            return result[0]
        } catch let error as NSError {
            print("Error while fetching Subject: \(error)")
            return SubjectMO()
        }
    }
    
    static func fetchOldestSubjectOverall() -> SubjectMO? {
        let allTopics = TopicMO.fetchAll()
        if !allTopics.isEmpty {
            var oldestSubjectOverall: SubjectMO?
            for topic in allTopics {
                let oldestInTopic = topic.fetchOldestSubjectInTopic()
                if oldestSubjectOverall?.sinceLastReviewedIn(.hour) ?? Int.min < oldestInTopic.sinceLastReviewedIn(.hour) {
                    oldestSubjectOverall = oldestInTopic
                }
            }
            return oldestSubjectOverall
        }
        return nil
    }
    
    func markAsReviewed() {
        timerToMarkAsReviewed = Timer.scheduledTimer(
            timeInterval: preferences.selectedTimeToMarkAsReviewedInSeconds, target: self, selector: #selector(updateWithNewLastReviewedDate), userInfo: nil, repeats: false)
    }
    
    @objc fileprivate func updateWithNewLastReviewedDate() {
        lastReviewed = NSDate()
        SubjectMO.update()
        NotificationCenter.default.post(name: .updatedSubject, object: name)
    }
    
    public override func prepareForDeletion() {
        abortMarkingAsReviewedIfTimeIsNotUp()
    }
    
    func abortMarkingAsReviewedIfTimeIsNotUp() {
        timerToMarkAsReviewed?.invalidate()
    }
    
    func sinceLastReviewedIn(_ dateComponent: Calendar.Component) -> Int {
        let dateDifference = Calendar.current.dateComponents([dateComponent], from: self.lastReviewed! as Date, to: Date())
        if dateComponent == .hour {
            return dateDifference.hour ?? 0
        }
        return dateDifference.day ?? 0
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
