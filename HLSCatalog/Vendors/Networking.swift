//
//  Networking.swift
//  HLSCatalog
//
//  Created by Alex Sklyarenko on 9/18/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation

enum HttpMethods: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

public enum Endpoints {
    case login
    case media(itemId: UInt)
    
    var domain: String { return Configs.API.baseURL }
    var scheme: String { return "https" }
    
    var httpMethod: String! {
        switch self {
        case .login:
            return "POST"
        case .media:
            return HttpMethods.get.rawValue
        }
    }
    
    var apiVersion:String { return Configs.API.apiVersion }
    
    var path: String {
        switch self {
        case .login:
            return "/login"
        case .media(let itemId):
            return "/media/\(itemId)"
        }
    }
}

enum NetError: Error {
    case serverError(message: String)
    case urlEncodeError
    case jsonDecodeError(message: String)
    case unknown
}

struct Networking {
    
    static func request<T: Codable>(endpoint: Endpoints,
                                    params: [String: String]?,
                                    completion: @escaping (Result<T, NetError>) -> Void) {
        
        var urlComponents = URLComponents()
        urlComponents.scheme = endpoint.scheme
        urlComponents.host = endpoint.domain
        urlComponents.path = "/\(endpoint.apiVersion)" + endpoint.path
        
        guard let url = urlComponents.url else {
            completion(.failure(.urlEncodeError))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.httpMethod
        
        if let params = params {
            encodeParamsForRequest(params: params, request: &request)
        }
        
        // Authed request
        if AuthManager.shared.isUserAuthorized() {
            request.addValue(AuthManager.shared.currentUser()?.authToken ?? "", forHTTPHeaderField: " X-Auth-Token")
        }
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error { completion(.failure(.serverError(message: error.localizedDescription))) }
            guard let data = data else {
                completion(.failure(.unknown))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.unknown))
                return
            }
            
            // Validate status code
            // TODO: Handle error codes for each case
            guard 200..<300 ~= response.statusCode else {
                let response = try? JSONDecoder().decode(NetworkResponseError.self, from: data)
                completion(.failure(.serverError(message: response?.data?.messageDescription ?? "")))
                return
            }
            
            do {
                let result = try JSONDecoder().decode(NetworkResponseData<T>.self, from: data)
                guard let data = result.data else {
                    completion(.failure(.unknown))
                    return
                }
                completion(.success(data))
            } catch let error {
                completion(.failure(.jsonDecodeError(message: error.localizedDescription)))
            }
        }
        task.resume()
    }
    
    fileprivate static func encodeParamsForRequest(params: [String: String], request: inout URLRequest) {
        switch request.httpMethod {
        case HttpMethods.get.rawValue:
            request.urlEncodeParameters(parameters: params)
        default:
            request.jsonEncodeParams(parameters: params)
        }
    }
}

// MARK: - URLRequest extension for params encoding
extension URLRequest {
    mutating func urlEncodeParameters(parameters: [String : String]) {
        guard let url = self.url else { return }
        if let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            var queryParams = [URLQueryItem]()
            for (key, value) in parameters {
                queryParams.append(URLQueryItem(name: key, value: value))
            }
            if !queryParams.isEmpty {
                self.url = urlComponents.url
            }
        }
    }
    
    mutating func jsonEncodeParams(parameters: [String : String]) {
        self.setValue("application/json", forHTTPHeaderField: "Content-Type")
        httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
    }
}
