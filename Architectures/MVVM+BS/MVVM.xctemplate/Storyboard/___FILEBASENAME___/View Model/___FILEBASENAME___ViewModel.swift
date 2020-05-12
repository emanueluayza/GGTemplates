//___FILEHEADER___

import Foundation
import Combine

class ___FILEBASENAMEASIDENTIFIER___ {
    
    // MARK: - Private Properties
    
    private let service: ___VARIABLE_productName:identifier___ServiceProtocol
    private var subscriber: AnyCancellable?
    private var models: [___VARIABLE_productName:identifier___] {
        didSet {
            modelsCount = models.count
            selectedModel = models.first
        }
    }
    
    // MARK: - Public Properties
    
    var modelsCount: Int
    var selectedModel: ___VARIABLE_productName:identifier___?
    var didStartRequest: (() -> ())?
    var didEndRequest: ((_ error: Error?) -> ())?
    
    // MARK: - Inits
    
    init(with model: ___VARIABLE_productName:identifier___? = nil, with serviceProtocol: ___VARIABLE_productName:identifier___ServiceProtocol = ___VARIABLE_productName:identifier___Service()) {
        service = serviceProtocol
        modelsCount = 0
        models = model != nil ? [model!] : [___VARIABLE_productName:identifier___]()
    }
    
    // MARK: - Choose model
    
    func selectModel(at index: Int) {
        selectedModel = models[index]
    }
}

// MARK: - ___VARIABLE_productName:identifier___ServiceProtocol

extension ___FILEBASENAMEASIDENTIFIER___ {
    func add___VARIABLE_productName:identifier___() {
        guard let model = selectedModel else { return }
    
        didStartRequest?()
                
        subscriber = service.add___VARIABLE_productName:identifier___(model: model).sink(receiveCompletion: { [weak self] (completion) in
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
    
    func delete___VARIABLE_productName:identifier___() {
        guard let model = selectedModel else { return }
    
        didStartRequest?()
        
        subscriber = service.delete___VARIABLE_productName:identifier___(model: model).sink(receiveCompletion: { [weak self] (completion) in
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
    
    func get___VARIABLE_productName:identifier___s() {
        didStartRequest?()
        
        subscriber = service.get___VARIABLE_productName:identifier___s().sink(receiveCompletion: { [weak self] (completion) in
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
    
    func update___VARIABLE_productName:identifier___() {
        guard let model = selectedModel else { return }
    
        didStartRequest?()
                
        subscriber = service.update___VARIABLE_productName:identifier___(model: model).sink(receiveCompletion: { [weak self] (completion) in
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
}
