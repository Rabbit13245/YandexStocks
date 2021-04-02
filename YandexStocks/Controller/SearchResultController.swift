//
//  SearchViewController.swift
//  YandexStocks
//
//  Created by Admin on 4/2/21.
//

import UIKit

class SearchResultController: UIViewController {
    
    // MARK: - UI
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        
        tableView.register(UINib(nibName: String(describing: StockTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: StockTableViewCell.self))
        tableView.register(UINib(nibName: String(describing: SuggestTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: SuggestTableViewCell.self))
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        view.backgroundColor = .red
    }
    
    // MARK: - Private methods
    private func setupView() {
        view.addSubview(tableView)
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
    }
    // MARK: - Public
}
