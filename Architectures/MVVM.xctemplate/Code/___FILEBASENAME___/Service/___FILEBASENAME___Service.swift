//___FILEHEADER___

import Foundation
import Combine

class ___FILEBASENAMEASIDENTIFIER___: ___FILEBASENAMEASIDENTIFIER___Protocol {
    
    // MARK: - API
    
    private struct ___VARIABLE_productName:identifier___Api {
        static let base = "https://jsonplaceholder.typicode.com"
        static let add = "/posts"
        static let delete = "/posts/"
        static let get = "/users"
        static let update = "/posts/"
    }
    
    // MARK: - BGHServiceProtocol
    
    func add___VARIABLE_productName:identifier___(model: ___VARIABLE_productName:identifier___) -> AnyPublisher<Void, Error> {
        let parameters: [String: Any] = ["title": model.title, "body": model.body, "userId": model.userId]

        guard let request =  ___VARIABLE_productName:identifier___Agent.createRequest(urlString: ___VARIABLE_productName:identifier___Api.base+___VARIABLE_productName:identifier___Api.add, method: .post, parameters: parameters) else {
            let error = URLError(.badURL)
            return Fail(error: error).eraseToAnyPublisher()
        }

        return  ___VARIABLE_productName:identifier___Agent.run(request, JSONDecoder())
    }
    
    func delete___VARIABLE_productName:identifier___(model: ___VARIABLE_productName:identifier___) -> AnyPublisher<Void, Error> {
        guard let request =  ___VARIABLE_productName:identifier___Agent.createRequest(urlString: ___VARIABLE_productName:identifier___Api.base+___VARIABLE_productName:identifier___Api.delete+"\(model.id)", method: .delete, parameters: nil) else {
            let error = URLError(.badURL)
            return Fail(error: error).eraseToAnyPublisher()
        }

        return  ___VARIABLE_productName:identifier___Agent.run(request, JSONDecoder())
    }
    
    func get___VARIABLE_productName:identifier___() -> AnyPublisher<[___VARIABLE_productName:identifier___], Error> {
        guard let url = URL(string: ___VARIABLE_productName:identifier___Api.base+___VARIABLE_productName:identifier___Api.get) else {
            let error = URLError(.badURL)
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return  ___VARIABLE_productName:identifier___Agent.run(URLRequest(url: url), JSONDecoder())
            .map(\.value)
            .eraseToAnyPublisher()
    }
    
    func update___VARIABLE_productName:identifier___(model: ___VARIABLE_productName:identifier___) -> AnyPublisher<Void, Error> {
        let parameters: [String: Any] = ["title": model.title, "body": model.body, "userId": model.userId]

        guard let request =  ___VARIABLE_productName:identifier___Agent.createRequest(urlString: ___VARIABLE_productName:identifier___Api.base+___VARIABLE_productName:identifier___Api.update+"\(model.id)", method: .put, parameters: parameters) else {
            let error = URLError(.badURL)
            return Fail(error: error).eraseToAnyPublisher()
        }

        return  ___VARIABLE_productName:identifier___Agent.run(request, JSONDecoder())
    }
}

// MARK: - Agent

struct ___VARIABLE_productName:identifier___Agent {
    
    // MARK: - Enums
    
    enum HTTPMethods: String {
        case post = "POST"
        case get = "GET"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    // MARK: - Structs
    
    struct ___VARIABLE_productName:identifier___Response<T> {
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
    
    static func run<T: Decodable>(_ request: URLRequest, _ decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<___VARIABLE_productName:identifier___Response<T>, Error> {
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { result -> ___VARIABLE_productName:identifier___Response<T> in
                let value = try decoder.decode(T.self, from: result.data)
                return ___VARIABLE_productName:identifier___Response(value: value, response: result.response)
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
