//
//  CollectionExtensions.swift
//  SMFramework
//
//  Created by 박성민 on 2021/09/01.
//

import Foundation

public extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
    
    var isNotEmpty: Bool {
        !isEmpty
    }
}

public extension MutableCollection {
    subscript(safe index: Index) -> Element? {
        set {
            if let newValue = newValue, indices.contains(index) {
                self[index] = newValue
            }
        }
        
        get {
            return indices.contains(index) ? self[index] : nil
        }
    }
}
