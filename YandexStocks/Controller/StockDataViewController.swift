//
//  StockDataViewController.swift
//  YandexStocks
//
//  Created by Дмитрий Зайцев on 26.03.2021.
//

import UIKit
import Charts
import NotificationBannerSwift

enum StockDataSegments {
    case news
    case sumamary
    case chart
}

class StockDataViewController: UIViewController {

    private let segments = ["News", "Summary", "Charts"]
    private let chartSegments = ["Week", "Month", "Year"]
    private var stock: Stock
    private var currentVisibleData: StockDataSegments = .news {
        didSet {
            switch currentVisibleData {
            case .news:
                setupAndShowNews()
            case .sumamary:
                setupAndShowSummary()
            case .chart:
                setupAndShowCharts()
            }
        }
    }
    private var currentVisibleChartInterval: ChartsRequestType = .week {
        didSet {
            startLoading()
            chartsData.loadData(requestType: currentVisibleChartInterval)
        }
    }
    
    private let newsDelegate = NewsTableViewDelegate()
    private let newsDataSource = NewsTableViewDataSource()
    private lazy var newsStockData = NewsStockData(ticker: stock.ticker)
    
    private let companyProfileDelegate = CompanyProfileDelegate()
    private let companyProfileDataSource = CompanyProfileDataSource()
    private lazy var companyProfileData = CompanyProfileData(ticker: stock.ticker)
    
    private lazy var chartsData = ChartsData(ticker: stock.ticker, requestType: currentVisibleChartInterval)
    
    // MARK: - UI
    private lazy var stockHeader: StockHeaderView = {
        let header = StockHeaderView(segments: segments)
        header.translatesAutoresizingMaskIntoConstraints = false
        header.valueChangedCallback = {[weak self] (value) in
            self?.valueChanged(value)
        }
        return header
    }()
    
    private lazy var chartFooter: StockHeaderView = {
        let footer = StockHeaderView(segments: chartSegments)
        footer.translatesAutoresizingMaskIntoConstraints = false
        footer.valueChangedCallback = { [weak self] (value) in
            self?.chartIntervalValueChanged(value)
        }
        return footer
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UINib(nibName: String(describing: StockNewsTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: StockNewsTableViewCell.self))
        tableView.register(UINib(nibName: String(describing: CompanyProfileTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: CompanyProfileTableViewCell.self))
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView(frame: .zero)
        return tableView
    }()
    
    private lazy var chartsView: LineChartView = {
        let view = LineChartView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.noDataText = "Can't fetch data of this time"
        
        view.rightAxis.enabled = false
        view.leftAxis.enabled = true
        
        view.legend.enabled = false
        
        view.xAxis.granularity = 1
        view.xAxis.drawGridLinesEnabled = true
        
        view.leftAxis.drawGridLinesEnabled = false
        
        view.xAxis.avoidFirstLastClippingEnabled = true
        //view.leftAxis.valueFormatter = YAxisValueFormatter()
        view.xAxis.forceLabelsEnabled = false
        view.fitScreen()
        return view
    }()
    
    private lazy var loading: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        return indicator
    }()
    
    private lazy var loadingBarButton: UIBarButtonItem = {
        let barButton = UIBarButtonItem(customView: loading)
        return barButton
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        currentVisibleData = .news
    }
    
    // MARK: - Initializers
    init(stock: Stock) {
        self.stock = stock
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    private func updateChart() {
        let dataSet = LineChartDataSet(entries: chartsData.createChartArray(), label: "Price")
        chartsView.xAxis.valueFormatter = IndexAxisValueFormatter(values: chartsData.stockChartData.formattedDesctiprion)
        
        dataSet.colors = [UIColor.label]
        dataSet.highlightEnabled = false
        dataSet.drawCirclesEnabled = false
        dataSet.drawCircleHoleEnabled = false
        dataSet.drawValuesEnabled = false
        dataSet.circleColors = [UIColor.label]
        dataSet.lineCapType = CGLineCap.round
        dataSet.mode = .horizontalBezier
        
        let data = LineChartData(dataSet: dataSet)
        chartsView.data = data
    }
    
    private func setupAndShowNews() {
        chartsView.animateHidding(hidding: true)
        chartFooter.animateHidding(hidding: true)
        tableView.animateHidding(hidding: false)
        
        newsDataSource.newsStockData = newsStockData
        newsDelegate.newsStockData = newsStockData
        
        newsStockData.asyncUpdateData = {[weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        newsStockData.fetchingDataCallback = {[weak self] (result) in
            DispatchQueue.main.async {
                self?.stopLoading()
                if !result {
                    let banner = StatusBarNotificationBanner(title: "Error fetching news. Reload", style: .danger)
                    banner.show()
                }
            }
        }
        
        startLoading()
        newsStockData.reloadData()
        DispatchQueue.main.async {
            self.tableView.delegate = self.newsDelegate
            self.tableView.dataSource = self.newsDataSource
            
            self.tableView.separatorStyle = .none
            self.tableView.reloadData()
        }
    }
    
    private func setupAndShowSummary() {
        chartsView.animateHidding(hidding: true)
        chartFooter.animateHidding(hidding: true)
        tableView.animateHidding(hidding: false)
        
        companyProfileDataSource.companyProfileData = companyProfileData
        companyProfileDelegate.companyProfileData = companyProfileData
        
        companyProfileData.asyncUpdateData = {[weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        companyProfileData.fetchingDataCallback = {[weak self] (result) in
            DispatchQueue.main.async {
                self?.stopLoading()
                if !result {
                    let banner = StatusBarNotificationBanner(title: "Error fetching company info. Reload", style: .danger)
                    banner.show()
                }
            }
        }
        
        startLoading()
        companyProfileData.reloadData()
        
        DispatchQueue.main.async {
            self.tableView.delegate = self.companyProfileDelegate
            self.tableView.dataSource = self.companyProfileDataSource
            
            self.tableView.separatorStyle = .singleLine
            self.tableView.reloadData()
        }
    }
    
    private func setupAndShowCharts() {
        chartsView.animateHidding(hidding: false)
        chartFooter.animateHidding(hidding: false)
        tableView.animateHidding(hidding: true)
        
        chartsData.updateChart = {[weak self] in
            self?.updateChart()
        }
        
        startLoading()
        chartsData.loadData(requestType: currentVisibleChartInterval)
        chartsData.fetchingDataCallback = {[weak self] (result) in
            DispatchQueue.main.async {
                self?.stopLoading()
                if !result {
                    let banner = StatusBarNotificationBanner(title: "Error fetching chart data. Reload", style: .danger)
                    banner.show()
                }
            }
        }
    }
    
    private func startLoading() {
        loading.startAnimating()
        navigationItem.rightBarButtonItem = loadingBarButton
        
        if currentVisibleData == .chart {
            chartFooter.isEnabled = false
        } else {
            chartFooter.isEnabled = true
        }
    }
    
    private func stopLoading() {
        loading.stopAnimating()
        navigationItem.rightBarButtonItem = nil
        
        chartFooter.isEnabled = true
    }
    
    private func setupView() {
        view.backgroundColor = UIColor.systemBackground
        
        view.addSubview(stockHeader)
        view.addSubview(tableView)
        view.addSubview(chartsView)
        view.addSubview(chartFooter)
        setupLayout()
        
        setupNavigation()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            stockHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            stockHeader.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            stockHeader.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            stockHeader.heightAnchor.constraint(equalToConstant: 44),
            
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: stockHeader.bottomAnchor,constant: 8),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            chartsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chartsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chartsView.topAnchor.constraint(equalTo: stockHeader.bottomAnchor,constant: 8),
            chartsView.bottomAnchor.constraint(equalTo: chartFooter.topAnchor),
            
            chartFooter.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            chartFooter.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            chartFooter.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            chartFooter.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
    
    private func setupNavigation() {
        navigationItem.backButtonTitle = ""
        let ticker = UILabel()
        ticker.text = stock.ticker
        ticker.font = Font.H3
        ticker.textAlignment = .center
        
        let name = UILabel()
        name.text = stock.name
        name.font = Font.Body
        name.textAlignment = .center
        
        let sv = UIStackView(arrangedSubviews: [ticker, name])
        sv.axis = .vertical
        sv.alignment = .fill
        sv.distribution = .equalSpacing
        navigationItem.titleView = sv
    }
    
    private func valueChanged(_ value: Int) {
        switch value {
        case 0:
            currentVisibleData = .news
        case 1:
            currentVisibleData = .sumamary
        case 2:
            currentVisibleData = .chart
        default:
            currentVisibleData = .news
        }
    }
    
    private func chartIntervalValueChanged(_ value: Int) {
        switch value {
        case 0:
            currentVisibleChartInterval = .week
        case 1:
            currentVisibleChartInterval = .month
        case 2:
            currentVisibleChartInterval = .year
        default:
            currentVisibleChartInterval = .week
        }
    }
}
