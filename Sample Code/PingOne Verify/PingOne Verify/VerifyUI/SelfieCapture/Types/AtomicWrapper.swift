//
//  AtomicWrapper.swift
//  ShoLib
//
//  Created by Bhavya Chauhan on 9/7/21.
//  Copyright © 2021 com.shocard. All rights reserved.
//

import Foundation

@propertyWrapper
public struct Atomic<Value> {
    
    private var value: Value
    private let lock = NSLock()
    
    public init(wrappedValue value: Value) {
        self.value = value
    }
    
    public var wrappedValue: Value {
        get { return load() }
        set { store(newValue: newValue) }
    }
    
    func load() -> Value {
        self.lock.lock()
        defer { self.lock.unlock() }
        return self.value
    }
    
    mutating func store(newValue: Value) {
        self.lock.lock()
        defer { self.lock.unlock() }
        self.value = newValue
    }
}
