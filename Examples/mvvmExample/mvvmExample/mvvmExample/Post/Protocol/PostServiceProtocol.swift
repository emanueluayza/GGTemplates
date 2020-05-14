//
//  PostServiceProtocol.swift
//  mvvmExample
//
//  Created by Emanuel Luayza on 14/05/2020.
//  Copyright © 2020 Emanuel Luayza. All rights reserved.
//

import Foundation
import Combine

protocol PostServiceProtocol {
    func addPost(model: Post) -> AnyPublisher<Void, Error>
    func deletePost(model: Post) -> AnyPublisher<Void, Error>
    func getPosts() -> AnyPublisher<[Post], Error>
    func updatePost(model: Post) -> AnyPublisher<Void, Error>
}
