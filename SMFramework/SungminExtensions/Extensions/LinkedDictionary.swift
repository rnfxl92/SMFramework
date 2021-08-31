//
//  LinkedDictionary.swift
//  
//
//  Created by 박성민 on 2021/08/30.
//

import Foundation

/// 순서를 가지는 String Dictinoary
class LinkedDictionary {

    fileprivate var keySet: [String] = [String]()
    fileprivate var values: [String: Any] = [String: Any]()
    
    var count: Int { keySet.count }

    /**
    키/값 쌍을 Dictionary에 추가한다
    
    - parameter key:   키
    - parameter value: 값
    */
    
    @discardableResult
    func addValue(_ key: String, value: Any) -> LinkedDictionary {
        if !keySet.contains(key) {
            self.keySet.append(key)
        }
        self.values[key] = value

        return self
    }
    
    /**
    지정된 키에 해당하는 값을 삭제한다
    - parameter key: 키
    */
    @discardableResult
    func removeValueForKey(_ key: String) -> Any? {
        if let index = keySet.firstIndex(of: key) {
            keySet.remove(at: index)
            return values.removeValue(forKey: key)
        }

        return nil
    }
    
    /**
    특정 키에 해당하는 값을 반환한다
    
    - parameter key: 반환받을 값의 키
    
    - returns: 반환값
    */
    func getValue(_ key: String) -> AnyObject {
        if let value = values[key] {
            return value as AnyObject
        } else {
            return NSObject()
        }
    }
    
    func getCompleteDictionoary() -> [String: AnyObject] {
        return values as [String: AnyObject]
    }
    
    /**
    Dictionary의 카운트를 반환한다
    
    - returns: Dictionary 카운트
    */
    func getCount() -> Int {
        return keySet.count
    }
    
    /**
    Dictionary의 특정 인덱스에 있는 키를 반환한다
    
    - parameter index: 받환받을 키의 인덱스
    
    - returns: 매개변수로 넘겨준 인덱스에 해당하는 키
    */
    func getKeyAtIndexOf(_ index: Int) -> String? {
        return keySet[safe: index]
    }
        
    /**
    Dictionary의 특정 인덱스에 있는 값을 반환한다
    
    - parameter index: 반환받을 값의 인덱스
    
    - returns: 매개변수로 넘겨준 인덱스에 해당하는 값
    */
    func getItemAtIndexOf(_ index: Int) -> AnyObject? {
        if index < keySet.count {
            let key: String = keySet[index]
            return values[key]! as AnyObject
        } else {
            return nil
        }
    }
    
    /**
     Dictionary상 값을 기준으로 인텍스를 반환한다
     
     - parameter value: 검색할 값
     
     - returns: 매개변수로 넘겨준 값에 해당하는 인덱스
     */
    func getIndexOfItem(_ value: AnyObject) -> Int? {
        for key in self.keySet {
            if let ext = self.values[key] {
                if value.isEqual(ext) {
                    return self.keySet.firstIndex(of: key)!
                }
            }
        }
        return nil
    }
    
    /**
     Dictionary상 값을 기준으로 인덱스를 반환한다
     
     - parameter key: 검색할 키
     
     - returns: 매개변수로 넘겨준 값에 해당하는 인덱스
     */
    func getIndexOfKey(_ key: String) -> Int? {
        return self.keySet.firstIndex(of: key)
    }
    
    /**
     현재 키 배열을 을 반환한다
     
     - returns: 키셋
     */
    func getKeys() -> [String] {
        return self.keySet
    }
    
    /**
     현재 값 배열을 반환한다
     
     - returns: 값 배열
     */
    func getValues() -> [AnyObject] {
        var values: [AnyObject] = []
        for key in self.keySet {
            if let ext = self.values[key] {
                values.append(ext as AnyObject)
            }
        }
        return values
    }
    
    /**
     Dictionary의 모든 항목을 제거한다
     */
    func removeAll() {
        self.keySet.removeAll()
        self.values.removeAll()
    }
    
}
