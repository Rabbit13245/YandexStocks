//
//  SearchViewController.swift
//  YandexStocks
//
//  Created by Admin on 4/2/21.
//

import UIKit

class SearchResultController: UIViewController {
    
    weak var delegate: ISuggestedSearch?
    var stocksData: TableStocksData?
    var favButtonPressed: ((StockTableViewCell) -> Void)?
    
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
        
        configureData()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIApplication.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.keyboardWillChangeFrameNotification, object: nil)
    }
    
    // MARK: - Private methods
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            tableView.contentInset = .zero
        } else {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }

        tableView.scrollIndicatorInsets = tableView.contentInset
    }
    
    private func configureData() {
        stocksData?.asyncSearchUpdateData = {[weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return showSuggestedSearches ? 130 : 76
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return showSuggestedSearches ? NSLocalizedString("Popular requests", comment: "") : ""
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let label = UILabel()
//        label.text = "Popular requests"
//        label.font = UIFont.boldSystemFont(ofSize: 18)
//        return showSuggestedSearches ? label : UIView()
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !showSuggestedSearches {
            guard let stocksData = stocksData,
                  let stock = stocksData.getStock(by: indexPath.row) else { return }
            delegate?.didSelectStock(stock: stock)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showSuggestedSearches {
            return 1
        } else {
            guard let count = stocksData?.searchResultStocks.count,
                  count > 0 else {
                tableView.isScrollEnabled = false
                return 0
            }
            tableView.isScrollEnabled = true
            return count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if showSuggestedSearches {
            guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: String(describing: SuggestTableViewCell.self),
                    for: indexPath) as? SuggestTableViewCell else { return UITableViewCell() }
            
            cell.didSelectPopularRequest = {[weak self] (query) in
                self?.delegate?.didSelectSuggestedItem(query: query)
            }
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: String(describing: StockTableViewCell.self),
                    for: indexPath) as? StockTableViewCell else { return UITableViewCell() }
            
            let model = stocksData?.searchResultStocks[indexPath.row]
            guard let safeModel = model else { return cell }
            
            if safeModel.change == "" {
                safeModel.getData2 { (result) in
                    if result {
                        DispatchQueue.main.async {
                            cell.configure(with: safeModel)
                        }
                    }
                }
            }
            
            if safeModel.logoUrl == nil {
                safeModel.getLogoUrl { (result) in
                    if result {
                        DispatchQueue.main.async {
                            cell.configure(with: safeModel)
                        }
                    }
                }
            }
            
            cell.configure(with: safeModel)
            cell.odd = indexPath.row % 2 > 0
            
            cell.favouriteButtonPressed = {[weak self] (cell) in
                self?.favButtonPressed?(cell)
            }
            return cell
        }
    }
}
