//___FILEHEADER___

import Foundation

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
        //guard let service = self.service else { return }
        
        //view?.didStartRequest()
        // Request here
        //view?.didEndRequest(nil)
    }
    
    func add___VARIABLE_productName:identifier___(model: ___VARIABLE_productName:identifier___) {
        //guard let service = self.service else { return }
        
        //view?.didStartRequest()
        // Request here
        //view?.didEndRequest(nil)
    }
    
    func delete___VARIABLE_productName:identifier___(model: ___VARIABLE_productName:identifier___) {
        //guard let service = self.service else { return }
        
        //view?.didStartRequest()
        // Request here
        //view?.didEndRequest(nil)
    }
    
    func update___VARIABLE_productName:identifier___(model: ___VARIABLE_productName:identifier___) {
        //guard let service = self.service else { return }
        
        //view?.didStartRequest()
        // Request here
        //view?.didEndRequest(nil)
    }
    
    func numberOfRows() -> Int {
        return models.count
    }
    
    func itemByIndex(index: Int) -> ___VARIABLE_productName:identifier___ {
        return models[index]
    }
}
