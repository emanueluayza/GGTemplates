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
    
    // MARK: - Inits
    
    init(with serviceProtocol: ___VARIABLE_productName:identifier___ServiceProtocol = ___VARIABLE_productName:identifier___Service()) {
        self.service = serviceProtocol
        self.modelsCount = 0
        self.models = [___VARIABLE_productName:identifier___]()
    }
    
    // MARK - ___VARIABLE_productName:identifier___ServiceProtocol
    
    func add___VARIABLE_productName:identifier___() {
        self.service.add___VARIABLE_productName:identifier___()
    }
    
    func delete___VARIABLE_productName:identifier___() {
        self.service.delete___VARIABLE_productName:identifier___()
    }
    
    func get___VARIABLE_productName:identifier___() {
        self.service.get___VARIABLE_productName:identifier___()
    }
    
    func update___VARIABLE_productName:identifier___() {
        self.service.update___VARIABLE_productName:identifier___()
    }
}

extension ___FILEBASENAMEASIDENTIFIER___ {

}
