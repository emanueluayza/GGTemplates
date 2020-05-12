//___FILEHEADER___

import UIKit

// MARK: - Protocols

protocol ___FILEBASENAMEASIDENTIFIER___Protocol {
    func setUpView()
}

// MARK: - Class

class ___FILEBASENAMEASIDENTIFIER___: UIViewController {

    // MARK: - IBOutlets
    
    // MARK: - Properties
    
    var indicator: UIActivityIndicatorView?
    lazy var presenter = ___VARIABLE_productName:identifier___Presenter(view: self)
        
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
        presenter.get___VARIABLE_productName:identifier___s()
    }
}

// MARK: - ___FILEBASENAMEASIDENTIFIER___Protocol

extension ___FILEBASENAMEASIDENTIFIER___: ___FILEBASENAMEASIDENTIFIER___Protocol {
    func setUpView() {
        indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        indicator?.center = view.center
        view.addSubview(indicator!)
    }
}

// MARK: - ___VARIABLE_productName:identifier___PresenterViewProtocol

extension ___FILEBASENAMEASIDENTIFIER___: ___VARIABLE_productName:identifier___PresenterViewProtocol {
    func didStartRequest() {
        indicator?.startAnimating()
    }
    
    func didEndRequest(_ error: Error?) {
        indicator?.stopAnimating()
    }
}

