//
//  Postervice.swift
//  mvpExample
//
//  Created by Emanuel Luayza on 14/05/2020.
//  Copyright © 2020 Emanuel Luayza. All rights reserved.
//

import Foundation
import Combine

// MARK: - Protocols

protocol PosterviceProtocol {
    func addPost(model: Post) -> AnyPublisher<Void, Error>
    func deletePost(model: Post) -> AnyPublisher<Void, Error>
    func getPosts() -> AnyPublisher<[Post], Error>
    func updatePost(model: Post) -> AnyPublisher<Void, Error>
}

// MARK: - Class

class PostService: PosterviceProtocol {
    
    // MARK: - API
    
    // Replace Api with your urls
    private struct PostApi {
        static let base = "https://jsonplaceholder.typicode.com"
        static let add = "/Posts"
        static let delete = "/Posts/"
        static let get = "/Posts"
        static let update = "/Posts/"
    }
    
    // MARK: - PosterviceProtocol
    
    func addPost(model: Post) -> AnyPublisher<Void, Error> {
        // Define your own parameters
        let parameters: [String: Any] = ["title": model.title, "body": model.body, "userId": model.userId]

        guard let request =  BaseService.createRequest(urlString: PostApi.base+PostApi.add, method: .post, parameters: parameters) else {
            let error = URLError(.badURL)
            return Fail(error: error).eraseToAnyPublisher()
        }

        return BaseService.run(request, JSONDecoder())
    }
    
    func deletePost(model: Post) -> AnyPublisher<Void, Error> {
        // Replace id with your ID
        guard let request =  BaseService.createRequest(urlString: PostApi.base+PostApi.delete+"\(model.id)", method: .delete, parameters: nil) else {
            let error = URLError(.badURL)
            return Fail(error: error).eraseToAnyPublisher()
        }

        return BaseService.run(request, JSONDecoder())
    }
    
    func getPosts() -> AnyPublisher<[Post], Error> {
        guard let url = URL(string: PostApi.base+PostApi.get) else {
            let error = URLError(.badURL)
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return BaseService.run(URLRequest(url: url), JSONDecoder())
            .map(\.value)
            .eraseToAnyPublisher()
    }
    
    func updatePost(model: Post) -> AnyPublisher<Void, Error> {
        // Define your own parameters
        let parameters: [String: Any] = ["title": model.title, "body": model.body, "userId": model.userId]

        // Replace id with your ID
        guard let request = BaseService.createRequest(urlString: PostApi.base+PostApi.update+"\(model.id)", method: .put, parameters: parameters) else {
            let error = URLError(.badURL)
            return Fail(error: error).eraseToAnyPublisher()
        }

        return BaseService.run(request, JSONDecoder())
    }
}
