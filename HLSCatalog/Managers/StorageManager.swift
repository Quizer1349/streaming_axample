//
//  AuthPersistace.swift
//  HLSCatalog
//
//  Created by Alex Sklyarenko on 9/19/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation

public protocol StorageProtocol {
    func get(key: String) -> Any?
    func save(key: String, value: Any?)
    func update(key: String, _ newValue: Any?)
    func delete(key: String)
}

fileprivate class UserDefaultStorage: StorageProtocol {
    
    fileprivate let storage = UserDefaults.standard
    
    func get(key: String) -> Any? {
        return storage.value(forKey: key)
    }
    
    func save(key: String, value: Any?) {
        storage.set(value, forKey: key)
    }
    
    func update(key: String, _ newValue: Any?) {
        storage.set(newValue, forKey: key)
    }
    
    func delete(key: String) {
        storage.removeObject(forKey: key)
    }
}

// TODO: Keychain storage for security cases
public final class StorageManager {
    
    private var storage: StorageProtocol
    static let standart = StorageManager()
    
    private init() {
        self.storage = UserDefaultStorage()
    }
    
    public init(storage: StorageProtocol) {
        self.storage = storage
    }
    
    public func isEmpty(forKey key: String) -> Bool {
        return storage.get(key: key) != nil
    }
    
    public func get(key: String) -> Any? {
        return storage.get(key: key)
    }
    
    public func save(key: String, value: Any?) {
        storage.save(key: key, value: value)
    }
    
    public func update(key: String, _ newValue: Any?) {
        storage.update(key: key, newValue)
    }
    
    public func delete(key: String) {
        storage.delete(key: key)
    }
}


