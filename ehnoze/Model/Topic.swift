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
        let topic = Topic(name: "Arrays and Strings")
        for itemDictionaryEntry in savedItems {
            topic.items.append(itemDictionaryEntry.value)
        }
        var topics = [Topic]()
        topics.append(topic)
        return topics
    }
}
