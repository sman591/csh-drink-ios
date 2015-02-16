//
//  Dynamic.swift
//  CSH Drink
//
//  Created by Stuart Olivera on 2/16/15.
//  Copyright (c) 2015 Stuart Olivera. All rights reserved.
//
//  Source: http://rasic.info/bindings-generics-swift-and-mvvm/

import Foundation

class Dynamic<T> {
    typealias Listener = T -> Void
    var listener: Listener?
    
    func bind(listener: Listener?) {
        self.listener = listener
    }
    
    func bindAndFire(listener: Listener?) {
        self.listener = listener
        listener?(value)
    }
    
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    init(_ v: T) {
        value = v
    }
}