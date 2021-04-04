//
//  SearchViewController.swift
//  YandexStocks
//
//  Created by Admin on 4/2/21.
//

import UIKit

class SearchResultController: UIViewController {
    
    var showSuggestedSearches: Bool = false {
        didSet {
            if oldValue != showSuggestedSearches {
                tableView.reloadData()
            }
        }
    }
    
    // MARK: - UI
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        
        tableView.register(UINib(nibName: String(describing: StockTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: StockTableViewCell.self))
        tableView.register(UINib(nibName: String(describing: SuggestTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: SuggestTableViewCell.self))
        
        tableView.delegate = self
        tableView.dataSource = self
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - Private methods
    private func setupView() {
        view.backgroundColor = UIColor.systemBackground
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

extension SearchResultController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showSuggestedSearches ? 1 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if showSuggestedSearches {
            guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: String(describing: SuggestTableViewCell.self),
                    for: indexPath) as? SuggestTableViewCell else { return UITableViewCell() }
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: String(describing: StockTableViewCell.self),
                    for: indexPath) as? StockTableViewCell else { return UITableViewCell() }
            
            return cell
        }
    }
}
