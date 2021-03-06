//
//  StocksViewController.swift
//  YandexStocks
//
//  Created by Admin on 3/23/21.
//

import UIKit
import NotificationBannerSwift

protocol ISuggestedSearch: class {
    func didSelectSuggestedItem(query: String)
    func didSelectStock(stock: Stock)
}

enum StockSegments: Int {
    case trend = 0
    case favourite = 1
    case search = 2
}

class StocksViewController: UIViewController {

    // MARK: - Private properties
    private var banner: StatusBarNotificationBanner?
    private let segments = ["Stocks", "Favourite"]
    private let cellId = "StockCellId"
    private var currentVisibleData: StockSegments = .trend
    private var currentSegment = 0 {
        didSet {
            currentVisibleData = StockSegments(rawValue: currentSegment) ?? .trend
        }
    }
    
    private lazy var tableViewDelegate = StocksTableViewDelegate()
    private lazy var tableViewDataSource = StocksTableViewDataSource()
    private lazy var tableStocksData = TableStocksData()
    private lazy var searchResultController = SearchResultController()
    
    // MARK: - UI
    private lazy var stockHeader: StockHeaderView = {
        let header = StockHeaderView(segments: segments)
        header.translatesAutoresizingMaskIntoConstraints = false
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
        return tableView
    }()
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: searchResultController)
        searchController.searchBar.placeholder = "Find company or ticker"
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        //searchController.obscuresBackgroundDuringPresentation = false
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
    
    private lazy var loading: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        configureData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(webSocketError), name: Notification.Name("WebsocketsError"), object: nil)
    }
    
    // MARK: - Public methods
    func changeFavourite(_ cell: StockTableViewCell) {
        tableStocksData.changeFavourite(cell)
    }
    
    // MARK: - Private methods
    @objc private func webSocketError() {
        banner?.dismiss()
        banner = StatusBarNotificationBanner(title: "Error websockets. Remove fav stocks and restart the app", style: .danger)
        banner?.show()
    }
    private func configureData() {
        tableViewDataSource.stocksData = tableStocksData
        tableViewDataSource.currentVC = self
        
        tableViewDelegate.stocksData = tableStocksData
        tableViewDelegate.delegate = self
        
        tableStocksData.asyncUpdateData = {[weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        tableStocksData.fetchingDataCallback = {[weak self] (result) in
            DispatchQueue.main.async {
                self?.stopLoading()
                if !result {
                    self?.banner?.dismiss()
                    self?.banner = StatusBarNotificationBanner(title: "Error fetching stocks. Restart the app", style: .danger)
                    self?.banner?.show()
                }
            }
        }
        tableStocksData.stockPriceUpdateCallback = {[weak self] (ticker, newPrice) in
            self?.priceUpdated(ticker: ticker, newPrice: newPrice)
        }
        
        tableStocksData.loadData()
        startLoading()
        tableView.dataSource = tableViewDataSource
        tableView.delegate = tableViewDelegate
        
        searchResultController.stocksData = tableStocksData
        searchResultController.favButtonPressed = {[weak self] (cell) in
            self?.changeFavourite(cell)
        }
        searchResultController.delegate = self
    }
    
    private func setupView() {
        let leftItem = UIBarButtonItem(customView: titleStackView)
        navigationItem.leftBarButtonItem = leftItem
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        view.backgroundColor = UIColor.systemBackground

        view.addSubview(stockHeader)
        view.addSubview(tableView)
        view.addSubview(loading)
        setupLayout()
        
        definesPresentationContext = true
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            stockHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            stockHeader.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            stockHeader.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            stockHeader.heightAnchor.constraint(equalToConstant: 44),
            
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: stockHeader.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loading.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loading.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func startLoading() {
        loading.startAnimating()
        loading.animateHidding(hidding: false)
        tableView.animateHidding(hidding: true)
    }
    
    private func stopLoading() {
        loading.stopAnimating()
        loading.animateHidding(hidding: true)
        tableView.animateHidding(hidding: false)
    }
    
    private func valueChanged(_ value: Int) {
        currentSegment = value
        tableStocksData.changeVisibleStocks(currentVisibleData)
        tableView.reloadData()
    }
    
    private func priceUpdated(ticker: String, newPrice: Double) {
        print("\(ticker) - \(newPrice)")
    }
}

extension StocksViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        currentVisibleData = .search
        tableStocksData.changeVisibleStocks(currentVisibleData)
        if let text = searchBar.text,
           text.isEmpty {
            searchResultController.showSuggestedSearches = true
        } else {
            searchResultController.showSuggestedSearches = false
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        currentVisibleData = StockSegments(rawValue: currentSegment) ?? .trend
        tableStocksData.changeVisibleStocks(currentVisibleData)
        tableView.reloadData()
//        stockHeader.segControlEnabled = true
    }
}

extension StocksViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let query = searchController.searchBar.text,
           query != "" {
            tableStocksData.search(query)
        }
    }
}

extension StocksViewController: UISearchControllerDelegate {
    func presentSearchController(_ searchController: UISearchController) {
        searchController.showsSearchResultsController = true
        searchResultController.showSuggestedSearches = true
    }
}

extension StocksViewController: ISuggestedSearch {
    func didSelectSuggestedItem(query: String) {
        navigationItem.searchController?.searchBar.text = query
        currentVisibleData = .search
        tableStocksData.changeVisibleStocks(currentVisibleData)
        searchResultController.showSuggestedSearches = false
        tableStocksData.search(query)
    }
    
    func didSelectStock(stock: Stock) {
        let stockDataVC = StockDataViewController(stock: stock)
        navigationController?.pushViewController(stockDataVC, animated: true)
    }
}
