//___FILEHEADER___

import Foundation

class ___FILEBASENAMEASIDENTIFIER___ {
    
    // MARK: - Private Properties
    
    private let service: ___VARIABLE_productName:identifier___ServiceProtocol
    private var model: [___VARIABLE_productName:identifier___Model] {
        didSet { modelCount = model.count }
    }
    
    // MARK: - Public Properties
    
    var modelCount: Int
    
    // MARK: - Inits
    
    init(with___VARIABLE_productName:identifier___ serviceProtocol: ___VARIABLE_productName:identifier___ServiceProtocol = ___VARIABLE_productName:identifier___Service() ) {
        self.service = serviceProtocol
        self.modelCount = 0
        self.model = [___VARIABLE_productName:identifier___Model]()
    }
}

extension ___FILEBASENAMEASIDENTIFIER___ {

}
