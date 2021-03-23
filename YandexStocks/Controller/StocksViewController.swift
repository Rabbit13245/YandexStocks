//
//  StocksViewController.swift
//  YandexStocks
//
//  Created by Admin on 3/23/21.
//

import UIKit

class StocksViewController: UIViewController {

    // MARK: - Private properties
    private let segments = ["Stocks", "Favourite"]
    private let cellId = "StockCellId"
    
    let tableViewDelegate = StocksTableViewDelegate()
    let tableViewDataSource = StocksTableViewDataSource()
    
    // MARK: - UI
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UINib(nibName: String(describing: StockTableViewCell.self), bundle: nil), forCellReuseIdentifier: StockTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.dataSource = tableViewDataSource
        tableView.delegate = tableViewDelegate
        return tableView
    }()
    
    private var searchController: UISearchController = {
        let searchController = UISearchController()
        searchController.searchBar.placeholder = "Find company or ticker"
        
        return searchController
    }()
    
    lazy var titleStackView: UIStackView = {
        let titleLabel = UILabel()
        titleLabel.text = "Yandex school"
        titleLabel.backgroundColor = .clear
        titleLabel.font = Font.H1
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        let result = formatter.string(from: date)
        let subtitleLabel = UILabel()
        subtitleLabel.text = result
        subtitleLabel.backgroundColor = .clear
        subtitleLabel.font = Font.H3
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.axis = .vertical
        
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - Private methods
    private func setupView() {
        let leftItem = UIBarButtonItem(customView: titleStackView)
        navigationItem.leftBarButtonItem = leftItem
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        
        view.addSubview(tableView)
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
}
