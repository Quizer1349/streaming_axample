//
//  UserModel.swift
//  HLSCatalog
//
//  Created by Alex Sklyarenko on 9/19/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation

struct UserModel: Codable {
    var wrapperKey: String = "message"
    
    var authToken: String?
    
    enum CodingKeys: String, CodingKey {
        case authToken = "auth_token"
    }
    
    init(authToken: String?) {
        self.authToken = authToken
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(authToken, forKey: .authToken)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        authToken = try container.decode(String?.self, forKey: .authToken)
    }
}
