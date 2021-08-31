//
//  AnyNameable.swift
//  
//
//  Created by 박성민 on 2021/08/30.
//

import Foundation

public protocol AnyNameable {
    static func className() -> String
}

public extension AnyNameable {
    static func className() -> String {
        return String(describing: self)
    }
}

extension NSObject: AnyNameable {}
