//
//  Preferences.swift
//  revizi
//
//  Created by Carlos Luz on 2019-01-19.
//

import Foundation

struct Preferences {
    fileprivate let timeToMarkAsReviewedKey = "selectedTimeToMarkAsReviewed"
    let defaultTimeToMarkAsReviewedInSeconds = 10
    var selectedTimeToMarkAsReviewedInSeconds: TimeInterval {
        get {
            let savedTime = UserDefaults.standard.double(forKey: timeToMarkAsReviewedKey)
            if savedTime > 0 {
                return savedTime
            }
            return Double(defaultTimeToMarkAsReviewedInSeconds)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: timeToMarkAsReviewedKey)
        }
    }
}
