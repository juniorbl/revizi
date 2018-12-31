//
//  NSManagedObjectExtension.swift
//  ehnoze
//
//  Created by Carlos on 2018-12-31.
//  Copyright © 2018 Carlos Luz. All rights reserved.
//

import Cocoa

extension NSManagedObject {
    
    static func validatesAbsenceOf(_ value: String) -> Bool {
        let trimmedValue = value.trimmingCharacters(in: .whitespaces)
        if trimmedValue == "" {
            return false
        }
        return true
    }
}
