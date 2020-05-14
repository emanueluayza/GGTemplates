//
//  PostView.swift
//  mvpExample
//
//  Created by Emanuel Luayza on 14/05/2020.
//  Copyright © 2020 Emanuel Luayza. All rights reserved.
//

import UIKit

// MARK: - Protocols

protocol PostViewProtocol {
    func setUpView()
}

// MARK: - Class

class PostView: UIViewController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    var indicator: UIActivityIndicatorView?
    lazy var presenter = PostPresenter(view: self)
    
    // MARK: - Constants
    
    struct Constants {
        static let cellID = "cellID"
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
    }
    
    // MARK: - IBActions
    
    @IBAction func getAction(_ sender: Any) {
        presenter.getPosts()
    }
}

// MARK: - PostViewProtocol

extension PostView: PostViewProtocol {
    func setUpView() {
        indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        indicator?.center = view.center
        view.addSubview(indicator!)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.cellID)
        tableView.tableFooterView = UIView()
    }
}

// MARK: - PostPresenterViewProtocol

extension PostView: PostPresenterViewProtocol {
    func didStartRequest() {
        indicator?.startAnimating()
    }
    
    func didEndRequest(_ error: Error?) {
        indicator?.stopAnimating()
        tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate

extension PostView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

// MARK: - UITableViewDataSource

extension PostView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellID) ?? UITableViewCell(style: .subtitle, reuseIdentifier: Constants.cellID)
        let post = presenter.itemByIndex(index: indexPath.row)
        cell.textLabel?.text = post.title
        return cell
    }
}

