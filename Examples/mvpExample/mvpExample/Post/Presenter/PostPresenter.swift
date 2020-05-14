//
//  PostPresenter.swift
//  mvpExample
//
//  Created by Emanuel Luayza on 14/05/2020.
//  Copyright © 2020 Emanuel Luayza. All rights reserved.
//

import Foundation
import Combine

// MARK: - Protocols

protocol PostPresenterViewProtocol: class {
    func didStartRequest()
    func didEndRequest(_ error: Error?)
}

protocol PostPresenterProtocol {
    func getPosts()
    func addPost(model: Post)
    func deletePost(model: Post)
    func updatePost(model: Post)
    func numberOfRows() -> Int
    func itemByIndex(index: Int) -> Post
}

// MARK: - Class

class PostPresenter {
    
    // MARK: - Properties
    
    private let service: PostService?
    private weak var view: PostPresenterViewProtocol?
    private var subscriber: AnyCancellable?
    private var models: [Post]
        
    // MARK: - Inits
    
    init(with service: PostService? = PostService(), view: PostPresenterViewProtocol) {
        self.service = service
        self.view = view
        self.models = [Post]()
    }
}

// MARK: - PostPresenterProtocol

extension PostPresenter: PostPresenterProtocol {
    func getPosts() {
        guard let service = self.service else { return }
        
        view?.didStartRequest()
        
        subscriber = service.getPosts().sink(receiveCompletion: { [weak self] (completion) in
            guard let strongSelf = self else { return }
            
            switch completion {
            case .failure(let error): strongSelf.view?.didEndRequest(error)
                case .finished: do {
                    strongSelf.view?.didEndRequest(nil)
                    strongSelf.subscriber?.cancel()
                }
            }
        }) { [weak self] (models) in
            guard let strongSelf = self else { return }
            strongSelf.models = models
        }
    }
    
    func addPost(model: Post) {
        guard let service = self.service else { return }
    
        view?.didStartRequest()
                
        subscriber = service.addPost(model: model).sink(receiveCompletion: { [weak self] (completion) in
            guard let strongSelf = self else { return }
            
            switch completion {
                case .failure(let error): strongSelf.view?.didEndRequest(error)
                case .finished: do {
                    strongSelf.view?.didEndRequest(nil)
                    strongSelf.subscriber?.cancel()
                }
            }
        }, receiveValue: {})
    }
    
    func deletePost(model: Post) {
        guard let service = self.service else { return }
        
        view?.didStartRequest()
        
        subscriber = service.deletePost(model: model).sink(receiveCompletion: { [weak self] (completion) in
            guard let strongSelf = self else { return }
            
            switch completion {
                case .failure(let error): strongSelf.view?.didEndRequest(error)
                case .finished: do {
                    strongSelf.view?.didEndRequest(nil)
                    strongSelf.subscriber?.cancel()
                }
            }
        }, receiveValue: {})
    }
    
    func updatePost(model: Post) {
        guard let service = self.service else { return }
        
        view?.didStartRequest()
                
        subscriber = service.updatePost(model: model).sink(receiveCompletion: { [weak self] (completion) in
            guard let strongSelf = self else { return }
            
            switch completion {
                case .failure(let error): strongSelf.view?.didEndRequest(error)
                case .finished: do {
                    strongSelf.view?.didEndRequest(nil)
                    strongSelf.subscriber?.cancel()
                }
            }
        }, receiveValue: {})
    }
    
    func numberOfRows() -> Int {
        models.count
    }
    
    func itemByIndex(index: Int) -> Post {
        return models[index]
    }
}
