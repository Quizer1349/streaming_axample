//
//  NetworkResponseModel.swift
//  HLSCatalog
//
//  Created by Alex Sklyarenko on 9/19/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation


protocol NetworkResponse where Self: Codable {
    associatedtype T
    var data: T? { get set }
}

struct ApiErrorMessage: Codable {
    var message: [String: [String]]?
    var messageDescription: String {
        var messageAll = ""
        guard let message = message else {
            return messageAll
        }
        
        for (_, value) in message {
            messageAll = value.reduce(messageAll) { (desc, item) -> String in
                desc + "\(item) "
            }
        }
        
        return messageAll.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    enum CodingKeys: String, CodingKey {
        case message
        case statusCode = "status_code"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(message, forKey: .message)
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        message = try container.decode([String: [String]]?.self, forKey: .message)
    }
}

struct NetworkResponseError: NetworkResponse {
    typealias T = ApiErrorMessage
    var data: ApiErrorMessage?
    
    enum CodingKeys: String, CodingKey {
        case data = "error"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(data, forKey: .data)
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try container.decode(T?.self, forKey: .data)
    }
    
}

struct NetworkResponseData<T: Codable>: NetworkResponse {
    var status: String?
    var data: T?
    
    enum CodingKeys: String, CodingKey {
        case status
        case data = "data"
        case message = "message"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(status, forKey: .status)
        try container.encode(data, forKey: .data)
    }
    init(from decoder: Decoder) throws {
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if container.contains(.status) {
                status = try container.decode(String?.self, forKey: .status)
            }
            if container.contains(.data) {
                data = try container.decode(T?.self, forKey: .data)
            }
            if container.contains(.message) {
                data = try container.decode(T?.self, forKey: .message)
            }
        } catch {
            // TODO: automatically send a report about a corrupted data
            print(error)
        }

    }
}
