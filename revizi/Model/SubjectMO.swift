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
        if validatesAbsenceOf(subjectName) == false {
            return "The subject name cannot be empty" // TODO localize
        } else {
            return validatesUniquenessOf(subjectName)
        }
    }
    
    static func validateUpdate(newSubjectName: String, originalSubjectName: String) -> String? {
        if validatesAbsenceOf(newSubjectName) == false {
            return "The subject name cannot be empty" // TODO localize
        } else {
            let trimmedNewSubjectName = newSubjectName.trimmingCharacters(in: .whitespaces)
            let trimmedOriginalSubjectName = originalSubjectName.trimmingCharacters(in: .whitespaces)
            if trimmedNewSubjectName.caseInsensitiveCompare(trimmedOriginalSubjectName) != .orderedSame {
                return validatesUniquenessOf(trimmedNewSubjectName)
            }
        }
        return nil
    }
    
    static private func validatesUniquenessOf(_ name: String) -> String? {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        if SubjectMO.fetchBy(name: trimmedName) != nil {
            return "The subject name already exists" // TODO localize
        }
        return nil
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
    
    func markAsReviewedIn(_ timeInSeconds: Int) {
        timerToMarkAsReviewed = Timer.scheduledTimer(timeInterval: TimeInterval(timeInSeconds), target: self, selector: #selector(markAsReviewed), userInfo: nil, repeats: false)
    }
    
    @objc fileprivate func markAsReviewed() {
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
