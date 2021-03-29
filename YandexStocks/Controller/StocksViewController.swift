//
//  StocksViewController.swift
//  YandexStocks
//
//  Created by Admin on 3/23/21.
//

import UIKit

enum StockSegments {
    case favourite
    case trend
}

class StocksViewController: UIViewController {

    // MARK: - Private properties
    private let segments = ["Stocks", "Favourite"]
    private let cellId = "StockCellId"
    private var currentVisibleData: StockSegments = .trend
    private var currentSegment = 0 {
        didSet {
            if currentSegment == 0 {
                currentVisibleData = .trend
            } else {
                currentVisibleData = .favourite
            }
        }
    }
    
    let tableViewDelegate = StocksTableViewDelegate()
    let tableViewDataSource = StocksTableViewDataSource()
    let tableStocksData = TableStocksData()
    
    // MARK: - UI
    private lazy var stockHeader: StockHeaderView = {
        let header = StockHeaderView(segments: segments)
        header.valueChangedCallback = {[weak self] (value) in
            self?.valueChanged(value)
        }
        return header
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UINib(nibName: String(describing: StockTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: StockTableViewCell.self))
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.dataSource = tableViewDataSource
        tableView.delegate = tableViewDelegate
        
        tableViewDelegate.headerView = stockHeader
        return tableView
    }()
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController()
        searchController.searchBar.placeholder = "Find company or ticker"
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
        return searchController
    }()
    
    private lazy var titleStackView: UIStackView = {
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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        configureData()
        
    }
    
    // MARK: - Public methods
    func changeFavourite(_ cell: StockTableViewCell) {
        tableStocksData.changeFavourite(cell)
    }
    
    // MARK: - Private methods
    private func configureData() {
        tableViewDataSource.stocksData = tableStocksData
        tableViewDataSource.currentVC = self
        
        tableViewDelegate.stocksData = tableStocksData
        tableViewDelegate.vc = self
        
        tableStocksData.asyncUpdateData = {[weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    private func setupView() {
        let leftItem = UIBarButtonItem(customView: titleStackView)
        navigationItem.leftBarButtonItem = leftItem
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        
        view.backgroundColor = UIColor.systemBackground

        view.addSubview(tableView)
    
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func valueChanged(_ value: Int) {
        currentSegment = value
        tableStocksData.changeVisibleStocks(currentVisibleData)
        tableView.reloadData()
    }
}

extension StocksViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        tableStocksData.isSearch = true
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        stockHeader.segControlEnabled = false
    }
    
//    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//        isSearch = false
//        stockHeader.segControlEnabled = true
//    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        tableStocksData.isSearch = false
        stockHeader.segControlEnabled = true
    }
}

extension StocksViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let query = searchController.searchBar.text {
            tableStocksData.search(query)
        }
    }
}
