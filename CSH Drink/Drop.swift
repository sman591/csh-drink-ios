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
}
