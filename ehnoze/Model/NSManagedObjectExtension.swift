//
//  NSManagedObjectExtension.swift
//  ehnoze
//
//  Created by Carlos on 2018-12-31.
//  Copyright © 2018 Carlos Luz. All rights reserved.
//

import Cocoa

extension NSManagedObject {
    
    static var repository: DataRepository = DataRepository()
    
    static func fetchBy(id: NSManagedObjectID) -> NSManagedObject {
        do {
            let loadedModel = try repository.managedContext.existingObject(with: id)
            return loadedModel
        } catch let error as NSError {
            print("Error while fetching: \(error)")
            return NSManagedObject()
        }
    }
    
    static func update() {
        do {
            // this assumes that an instance of the model is already loaded in memory and just call the context to save,
            // maybe theres's a better way to do this
            try repository.managedContext.save()
        } catch let error as NSError {
            print("Error while updating: \(error)")
        }
    }
    
    static func delete(id: NSManagedObjectID) {
        do {
            let objectToDelete = fetchBy(id: id)
            repository.managedContext.delete(objectToDelete)
            try repository.managedContext.save()
        } catch let error as NSError {
            print("Error while deleting: \(error)")
        }
    }
    
    static func validatesAbsenceOf(_ value: String) -> Bool {
        let trimmedValue = value.trimmingCharacters(in: .whitespaces)
        if trimmedValue == "" {
            return false
        }
        return true
    }
}
