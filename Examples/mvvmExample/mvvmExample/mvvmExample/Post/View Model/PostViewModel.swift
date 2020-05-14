//
//  PostViewModel.swift
//  mvvmExample
//
//  Created by Emanuel Luayza on 14/05/2020.
//  Copyright © 2020 Emanuel Luayza. All rights reserved.
//

import Foundation
import Combine

class PostViewModel {
    
    // MARK: - Private Properties
    
    private let service: PostServiceProtocol
    private var subscriber: AnyCancellable?
    private var models: [Post] {
        didSet {
            modelsCount = models.count
            selectedModel = models.first
        }
    }
    
    // MARK: - Public Properties
    
    var modelsCount: Int
    var selectedModel: Post?
    var didStartRequest: (() -> ())?
    var didEndRequest: ((_ error: Error?) -> ())?
    
    // MARK: - Inits
    
    init(with model: Post? = nil, with serviceProtocol: PostServiceProtocol = PostService()) {
        service = serviceProtocol
        modelsCount = 0
        models = model != nil ? [model!] : [Post]()
    }
    
    // MARK: - Choose model
    
    func selectModel(at index: Int) {
        selectedModel = models[index]
    }
}

// MARK: - PostServiceProtocol

extension PostViewModel {
    func addPost() {
        guard let model = selectedModel else { return }
    
        didStartRequest?()
                
        subscriber = service.addPost(model: model).sink(receiveCompletion: { [weak self] (completion) in
            guard let strongSelf = self else { return }
            
            switch completion {
                case .failure(let error): strongSelf.didEndRequest?(error)
                case .finished: do {
                    strongSelf.didEndRequest?(nil)
                    strongSelf.subscriber?.cancel()
                }
            }
        }, receiveValue: {})
    }
    
    func deletePost() {
        guard let model = selectedModel else { return }
    
        didStartRequest?()
        
        subscriber = service.deletePost(model: model).sink(receiveCompletion: { [weak self] (completion) in
            guard let strongSelf = self else { return }
            
            switch completion {
                case .failure(let error): strongSelf.didEndRequest?(error)
                case .finished: do {
                    strongSelf.didEndRequest?(nil)
                    strongSelf.subscriber?.cancel()
                }
            }
        }, receiveValue: {})
    }
    
    func getPosts() {
        didStartRequest?()
        
        subscriber = service.getPosts().sink(receiveCompletion: { [weak self] (completion) in
            guard let strongSelf = self else { return }
            
            switch completion {
                case .failure(let error): strongSelf.didEndRequest?(error)
                case .finished: do {
                    strongSelf.didEndRequest?(nil)
                    strongSelf.subscriber?.cancel()
                }
            }
        }) { [weak self] (models) in
            guard let strongSelf = self else { return }
            strongSelf.models = models
        }
    }
    
    func updatePost() {
        guard let model = selectedModel else { return }
    
        didStartRequest?()
                
        subscriber = service.updatePost(model: model).sink(receiveCompletion: { [weak self] (completion) in
            guard let strongSelf = self else { return }
            
            switch completion {
                case .failure(let error): strongSelf.didEndRequest?(error)
                case .finished: do {
                    strongSelf.didEndRequest?(nil)
                    strongSelf.subscriber?.cancel()
                }
            }
        }, receiveValue: {})
    }
    
    func itemByIndex(index: Int) -> Post {
        return models[index]
    }
}
