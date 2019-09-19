//
//  AuthManager.swift
//  HLSCatalog
//
//  Created by Alex Sklyarenko on 9/19/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation

struct AuthManager {
    fileprivate struct StorageKeys {
        static let accessToken = "accessTokenKey"
    }
    
    static let shared = AuthManager()
    
    fileprivate init() {}
    
    func currentUser() -> UserModel? {
        let token = StorageManager.standart.get(key: StorageKeys.accessToken)
        guard let tokenLet = token as? String else { return nil }
        return UserModel(authToken: tokenLet)
    }
    
    func isUserAuthorized() -> Bool {
        return StorageManager.standart.isEmpty(forKey: StorageKeys.accessToken)
    }
    
    func loginUserWithToken(token: String) {
        StorageManager.standart.save(key: StorageKeys.accessToken, value: token)
    }
    
    func logoutUser() {
        StorageManager.standart.delete(key: StorageKeys.accessToken)
    }
}
