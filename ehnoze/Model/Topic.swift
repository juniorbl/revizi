//
//  Topic.swift
//  ehnoze
//
//  Created by Carlos on 2018-11-24.
//  Copyright © 2018 Carlos Luz. All rights reserved.
//

import Cocoa

class Topic: NSObject {
    let name: String
    var items = [Item]()
    
    init(name: String) {
        self.name = name
    }
    
    static func topicList() -> [Topic] {
        let savedItems = Item.listAll()
        let topic = Topic(name: "Some topic name")
        for itemDictionaryEntry in savedItems {
//            itemDictionaryEntry.value.lastReviewed.compare(other: Date())
//            let lastReviewed = Calendar.current.dateComponents([.day], from: itemDictionaryEntry.value.lastReviewed, to: Date()).day ?? 0
            topic.items.append(itemDictionaryEntry.value)
        }
        var topics = [Topic]()
        topics.append(topic)
        return topics
    }
}
