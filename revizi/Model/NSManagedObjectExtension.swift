//
//  NSManagedObjectExtension.swift
//  revizi
//
//  Created by Carlos on 2018-12-31.
//  Copyright © 2018 Carlos Luz. All rights reserved.
//

import Cocoa
import os

extension NSManagedObject {
    
    static var repository: DataRepository = DataRepository()
    
    static func fetchBy(id: NSManagedObjectID) -> NSManagedObject {
        do {
            let loadedModel = try repository.managedContext.existingObject(with: id)
            return loadedModel
        } catch let error as NSError {
            os_log("Error while fetching: %s", error)
            return NSManagedObject()
        }
    }
    
    static func update() {
        do {
            // this assumes that an instance of the model is already loaded in memory and just call the context to save,
            // maybe theres's a better way to do this
            try repository.managedContext.save()
        } catch let error as NSError {
            os_log("Error while updating: %s", error)
        }
    }
    
    static func delete(id: NSManagedObjectID) {
        do {
            let objectToDelete = fetchBy(id: id)
            repository.managedContext.delete(objectToDelete)
            try repository.managedContext.save()
        } catch let error as NSError {
            os_log("Error while deleting: %s", error)
        }
    }
    
    static func validateCreate(_ value: String, _ valueName: String, validationFunction: (String) -> NSManagedObject?, forElementName: String) -> String? {
        if validatesAbsenceOf(value) == false {
            return "The \(valueName) cannot be empty" // TODO localize
        } else {
            return validatesUniquenessOf(value, validationFunction: validationFunction, forElementName: forElementName)
        }
    }
    
    static func validateUpdate(_ newValue: String, _ originalValue: String, _ valueName: String, validationFunction: (String) -> NSManagedObject?, forElementName: String) -> String? {
        if validatesAbsenceOf(newValue) == false {
            return "The \(valueName) cannot be empty" // TODO localize
        } else {
            let trimmedNewValue = newValue.trimmingCharacters(in: .whitespaces)
            let trimmedOriginalValue = originalValue.trimmingCharacters(in: .whitespaces)
            if trimmedNewValue.caseInsensitiveCompare(trimmedOriginalValue) != .orderedSame {
                return validatesUniquenessOf(trimmedNewValue, validationFunction: validationFunction, forElementName: forElementName)
            }
        }
        return nil
    }
    
    fileprivate static func validatesAbsenceOf(_ value: String) -> Bool {
        let trimmedValue = value.trimmingCharacters(in: .whitespaces)
        if trimmedValue == "" {
            return false
        }
        return true
    }
    
    fileprivate static func validatesUniquenessOf(_ value: String, validationFunction: (String) -> NSManagedObject?, forElementName: String) -> String? {
        let trimmedValue = value.trimmingCharacters(in: .whitespaces)
        if validationFunction(trimmedValue) != nil {
            return "The \(forElementName) name already exists" // TODO localize
        }
        return nil
    }
}
