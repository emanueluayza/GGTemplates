//___FILEHEADER___

import UIKit

class ___FILEBASENAMEASIDENTIFIER___: UIViewController {
    
    // MARK: - IBOutlets
    
    // MARK: - Properties
    
    var indicator: UIActivityIndicatorView?
    let viewModel = ___VARIABLE_productName:identifier___ViewModel()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
        setUpViewModel()
    }
    
    // MARK: - Setups
    
    func setUpViewModel() {
        viewModel.didStartRequest = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.indicator?.startAnimating()
        }
        
        viewModel.didEndRequest = { [weak self] (error) in
            guard let strongSelf = self else { return }
            strongSelf.indicator?.stopAnimating()
        }
        
        viewModel.get___VARIABLE_productName:identifier___s()
    }
    
    func setUpView() {
        indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        indicator?.center = view.center
        view.addSubview(indicator!)
    }
}
