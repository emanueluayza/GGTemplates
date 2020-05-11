//___FILEHEADER___

import Foundation

class ___FILEBASENAMEASIDENTIFIER___ {
    
    // MARK: - Private Properties
    
    private let service: ___VARIABLE_productName:identifier___ServiceProtocol
    
    private var models: [___VARIABLE_productName:identifier___] {
        didSet { modelsCount = models.count }
    }
    
    // MARK: - Public Properties
    
    var modelsCount: Int
    var didStartRequest: (() -> ())?
    var didEndRequest: ((_ error: Error?) -> ())?
    
    // MARK: - Inits
    
    init(with serviceProtocol: ___VARIABLE_productName:identifier___ServiceProtocol = ___VARIABLE_productName:identifier___Service()) {
        service = serviceProtocol
        modelsCount = 0
        models = [___VARIABLE_productName:identifier___]()
    }
}

// MARK - ___VARIABLE_productName:identifier___ServiceProtocol

extension ___FILEBASENAMEASIDENTIFIER___ {
    func add___VARIABLE_productName:identifier___(model: ___VARIABLE_productName:identifier___) {

    }
    
    func delete___VARIABLE_productName:identifier___(model: ___VARIABLE_productName:identifier___) {

    }
    
    func get___VARIABLE_productName:identifier___() {

    }
    
    func update___VARIABLE_productName:identifier___(model: ___VARIABLE_productName:identifier___) {

    }
}
