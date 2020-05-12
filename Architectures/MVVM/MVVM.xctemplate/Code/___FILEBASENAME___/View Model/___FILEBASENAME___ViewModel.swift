//___FILEHEADER___

import Foundation

class ___FILEBASENAMEASIDENTIFIER___ {
    
    // MARK: - Private Properties
    
    private let service: ___VARIABLE_productName:identifier___ServiceProtocol
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
        //guard let model = selectedModel else { return }
    
        //didStartRequest?()
        // Request here
        //didEndRequest?(nil)
    }
    
    func delete___VARIABLE_productName:identifier___() {
        //guard let model = selectedModel else { return }
    
        //didStartRequest?()
        // Request here
        //didEndRequest?(nil)
    }
    
    func get___VARIABLE_productName:identifier___() {
        //didStartRequest?()
        // Request here
        //didEndRequest?(nil)
    }
    
    func update___VARIABLE_productName:identifier___() {
        //guard let model = selectedModel else { return }
    
        //didStartRequest?()
        // Request here
        //didEndRequest?(nil)
    }
}
