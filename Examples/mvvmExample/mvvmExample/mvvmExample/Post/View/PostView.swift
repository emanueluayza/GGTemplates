//
//  PostView.swift
//  mvvmExample
//
//  Created by Emanuel Luayza on 14/05/2020.
//  Copyright © 2020 Emanuel Luayza. All rights reserved.
//

import UIKit

class PostView: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    var indicator: UIActivityIndicatorView?
    let viewModel = PostViewModel()
    
    // MARK: - Constants
    
    struct Constants {
        static let cellID = "cellID"
    }
    
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
            strongSelf.tableView.reloadData()
            strongSelf.indicator?.stopAnimating()
        }
    }
    
    func setUpView() {
        indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        indicator?.center = view.center
        view.addSubview(indicator!)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.cellID)
        tableView.tableFooterView = UIView()
    }
    
    // MARK: - IBActions
    
    @IBAction func getAction(_ sender: Any) {
        viewModel.getPosts()
    }
}

// MARK: - UITableViewDelegate

extension PostView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.modelsCount
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

// MARK: - UITableViewDataSource

extension PostView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellID) ?? UITableViewCell(style: .subtitle, reuseIdentifier: Constants.cellID)
        let post = viewModel.itemByIndex(index: indexPath.row)
        cell.textLabel?.text = post.title
        return cell
    }
}
