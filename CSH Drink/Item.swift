//
//  Item.swift
//  CSH Drink
//
//  Created by Stuart Olivera on 1/21/15.
//  Copyright (c) 2015 Stuart Olivera. All rights reserved.
//

import Foundation

struct Item {
    let name: String
    let price: Int
    let machine_id: Int
    let slot_num: Int
    let available: Int
    
    func enabled() -> Bool {
        return available > 0
    }
}