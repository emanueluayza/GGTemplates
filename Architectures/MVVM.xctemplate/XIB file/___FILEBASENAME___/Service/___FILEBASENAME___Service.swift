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

        guard let request =  BaseService.createRequest(urlString: ___VARIABLE_productName:identifier___Api.base+___VARIABLE_productName:identifier___Api.add, method: .post, parameters: parameters) else {
            let error = URLError(.badURL)
            return Fail(error: error).eraseToAnyPublisher()
        }

        return BaseService.run(request, JSONDecoder())
    }
    
    func delete___VARIABLE_productName:identifier___(model: ___VARIABLE_productName:identifier___) -> AnyPublisher<Void, Error> {
        guard let request =  BaseService.createRequest(urlString: ___VARIABLE_productName:identifier___Api.base+___VARIABLE_productName:identifier___Api.delete+"\(model.id)", method: .delete, parameters: nil) else {
            let error = URLError(.badURL)
            return Fail(error: error).eraseToAnyPublisher()
        }

        return BaseService.run(request, JSONDecoder())
    }
    
    func get___VARIABLE_productName:identifier___() -> AnyPublisher<[___VARIABLE_productName:identifier___], Error> {
        guard let url = URL(string: ___VARIABLE_productName:identifier___Api.base+___VARIABLE_productName:identifier___Api.get) else {
            let error = URLError(.badURL)
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return BaseService.run(URLRequest(url: url), JSONDecoder())
            .map(\.value)
            .eraseToAnyPublisher()
    }
    
    func update___VARIABLE_productName:identifier___(model: ___VARIABLE_productName:identifier___) -> AnyPublisher<Void, Error> {
        let parameters: [String: Any] = ["title": model.title, "body": model.body, "userId": model.userId]

        guard let request = BaseService.createRequest(urlString: ___VARIABLE_productName:identifier___Api.base+___VARIABLE_productName:identifier___Api.update+"\(model.id)", method: .put, parameters: parameters) else {
            let error = URLError(.badURL)
            return Fail(error: error).eraseToAnyPublisher()
        }

        return BaseService.run(request, JSONDecoder())
    }
}
