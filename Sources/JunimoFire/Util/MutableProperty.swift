//
//  MutableProperty.swift
//
//
//  Created by 최준영 on 6/17/24.
//

import Foundation

actor MutableProperty<Value> {
    var value: Value
    
    init( value: Value) {
        self.value = value
    }
    
    func update(newValue: Value) {
        
        self.value = newValue
    }
    
    func write(_ writingClosure: (Value) -> Value) {
        self.value = writingClosure(self.value)
    }
}
