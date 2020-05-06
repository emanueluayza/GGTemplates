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
        
        let model = ___VARIABLE_productName:identifier___(id: 1, title: "foo", body: "bar", userId: 1)

        //viewModel.get___VARIABLE_productName:identifier___()
        //viewModel.add___VARIABLE_productName:identifier___(model: model)
        //viewModel.delete___VARIABLE_productName:identifier___(model: model)
        viewModel.update___VARIABLE_productName:identifier___(model: model)
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
    }
    
    func setUpView() {
        indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        indicator?.center = view.center
        view.addSubview(indicator!)
    }
}
