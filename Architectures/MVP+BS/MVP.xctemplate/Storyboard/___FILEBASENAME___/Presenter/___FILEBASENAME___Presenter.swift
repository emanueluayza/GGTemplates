//___FILEHEADER___

import Foundation
import Combine

// MARK: - Protocols

protocol ___FILEBASENAMEASIDENTIFIER___ViewProtocol: class {
    func didStartRequest()
    func didEndRequest(_ error: Error?)
}

protocol ___FILEBASENAMEASIDENTIFIER___Protocol {
    func get___VARIABLE_productName:identifier___s()
    func add___VARIABLE_productName:identifier___(model: ___VARIABLE_productName:identifier___)
    func delete___VARIABLE_productName:identifier___(model: ___VARIABLE_productName:identifier___)
    func update___VARIABLE_productName:identifier___(model: ___VARIABLE_productName:identifier___)
    func numberOfRows() -> Int
    func itemByIndex(index: Int) -> ___VARIABLE_productName:identifier___
}

// MARK: - Class

class ___FILEBASENAMEASIDENTIFIER___ {
    
    // MARK: - Properties
    
    private let service: ___VARIABLE_productName:identifier___Service?
    private weak var view: ___FILEBASENAMEASIDENTIFIER___ViewProtocol?
    private var subscriber: AnyCancellable?
    private var models: [___VARIABLE_productName:identifier___]
        
    // MARK: - Inits
    
    init(with service: ___VARIABLE_productName:identifier___Service? = ___VARIABLE_productName:identifier___Service(), view: ___FILEBASENAMEASIDENTIFIER___ViewProtocol) {
        self.service = service
        self.view = view
        self.models = [___VARIABLE_productName:identifier___]()
    }
}

// MARK: - ___FILEBASENAMEASIDENTIFIER___Protocol

extension ___FILEBASENAMEASIDENTIFIER___: ___FILEBASENAMEASIDENTIFIER___Protocol {
    func get___VARIABLE_productName:identifier___s() {
        guard let service = self.service else { return }
        
        view?.didStartRequest()
        
        subscriber = service.get___VARIABLE_productName:identifier___s().sink(receiveCompletion: { [weak self] (completion) in
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
    
    func add___VARIABLE_productName:identifier___(model: ___VARIABLE_productName:identifier___) {
        guard let service = self.service else { return }
    
        view?.didStartRequest()
                
        subscriber = service.add___VARIABLE_productName:identifier___(model: model).sink(receiveCompletion: { [weak self] (completion) in
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
    
    func delete___VARIABLE_productName:identifier___(model: ___VARIABLE_productName:identifier___) {
        guard let service = self.service else { return }
        
        view?.didStartRequest()
        
        subscriber = service.delete___VARIABLE_productName:identifier___(model: model).sink(receiveCompletion: { [weak self] (completion) in
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
    
    func update___VARIABLE_productName:identifier___(model: ___VARIABLE_productName:identifier___) {
        guard let service = self.service else { return }
        
        view?.didStartRequest()
                
        subscriber = service.update___VARIABLE_productName:identifier___(model: model).sink(receiveCompletion: { [weak self] (completion) in
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
        return models.count
    }
    
    func itemByIndex(index: Int) -> ___VARIABLE_productName:identifier___ {
        return models[index]
    }
}
