//
//  ChartsData.swift
//  YandexStocks
//
//  Created by Дмитрий Зайцев on 29.03.2021.
//

import Foundation
import Charts

enum ChartsRequestType {
    case week
    case month
    case year
}

class ChartsData {
    // MARK: - Public
    var stockChartData = StockChartData(valueGraphData: [Double](),
                                        rawDescription: [Int](),
                                        formattedDesctiprion: [String]()) {
        didSet {
            DispatchQueue.main.async {
                self.updateChart?()
            }
        }
    }
    
    var updateChart: (() -> Void)?
    
    // MARK: - Private
    private let ticker: String
    
    // MARK: - Dependencies
    private let companyManager = CompanyManager()
    // MARK: - Initializers
    init(ticker: String) {
        self.ticker = ticker
        
        loadData(requestType: .week)
    }
    
    func createChartArray() -> [ChartDataEntry] {
        var chartDataArray = [ChartDataEntry]()
        var i = 0
        for item in stockChartData.valueGraphData {
            chartDataArray.append(ChartDataEntry(x: Double(i), y: item))
            i += 1
        }
        
        return chartDataArray
    }
    
    // MARK: - Public
    func loadData(requestType: ChartsRequestType) {
        var res = "D"
        
        let today = Date()
        var from = TimeInterval()
        var to = TimeInterval()
        
        switch requestType {
        case .week:
            from = (today - 7).timeIntervalSince1970
            to = today.timeIntervalSince1970
        case .month:
            from = (today - 30).timeIntervalSince1970
            to = today.timeIntervalSince1970
        case .year:
            from = (today - 365).timeIntervalSince1970
            to = today.timeIntervalSince1970
            res = "M"
        }
        
        companyManager.getChartData(ticker: ticker,
                                    res: res,
                                    from: String(Int(from)),
                                    to: String(Int(to))) { [weak self] (result) in
            switch result {
            case .failure:
                print("error while fetching news")
            case .success(var data):
                data.formatDescription(with: requestType)
                self?.stockChartData = data
            }
        }
    }
}
