//
//  BaseService.swift
//  mvvmExample
//
//  Created by Emanuel Luayza on 14/05/2020.
//  Copyright © 2020 Emanuel Luayza. All rights reserved.
//

import Foundation
import Combine

struct BaseService {
    
    // MARK: - Http Methods
    
    enum HTTPMethods: String {
        case post = "POST"
        case get = "GET"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    // MARK: - Response
    
    struct Response<T> {
        let value: T
        let response: URLResponse
    }
    
    // MARK: - Requests
    
    static func createRequest(urlString: String, method: HTTPMethods, parameters: [String: Any]?) -> URLRequest? {
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        var request : URLRequest = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        if let params = parameters {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            } catch let error {
                print(error.localizedDescription)
            }
        }
        
        return request
    }
    
    static func run<T: Decodable>(_ request: URLRequest, _ decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<Response<T>, Error> {
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { result -> Response<T> in
                let value = try decoder.decode(T.self, from: result.data)
                return Response(value: value, response: result.response)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    static func run(_ request: URLRequest, _ decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<Void, Error> {
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap({ (data, response) -> Void in
                print(response)
            })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
