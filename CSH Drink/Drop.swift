//
//  Drop.swift
//  CSH Drink
//
//  Created by Stuart Olivera on 1/21/15.
//  Copyright (c) 2015 Stuart Olivera. All rights reserved.
//

import Foundation

struct Drop {
    let item_name: String
    let item_price: Int
    let machine_name: String
    let time: String
    
    func humanPrice() -> String {
        return "\(item_price) " + ("Credit".pluralize(count: item_price))
    }
    
    func timestamp() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-DD HH:mm:ss"
        return dateFormatter.date(from: time)
    }
    
    func relativeTime() -> String {
        if let date = timestamp() {
            return timeAgoSince(date)
        } else {
            return time
        }
    }
}
