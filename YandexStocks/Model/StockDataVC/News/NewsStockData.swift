//
//  NewsStockData.swift
//  YandexStocks
//
//  Created by Дмитрий Зайцев on 28.03.2021.
//

import Foundation

class NewsStockData {
    
    // MARK: - Public
    var asyncUpdateData: (() -> Void)?
    var news = [News]() {
        didSet {
            asyncUpdateData?()
        }
    }
    
    // MARK: - Private
    private let ticker: String
    
    // MARK: - Dependencies
    private let companyManager = CompanyManager()
    
    // MARK: - Initializers
    init(ticker: String) {
        self.ticker = ticker
        loadData()
    }
    
    // MARK: - Private
    private func loadData() {
        let toDate = Date().convertToString(with: "yyyy-MM-dd")
        let fromDate = (Date() - 30).convertToString(with: "yyyy-MM-dd")
        companyManager.getNews(ticker: ticker, from: fromDate, to: toDate) { [weak self] (result) in
            switch result {
            case .failure:
                print("error while fetching news")
            case .success(let data):
                self?.news = data
            }
        }
    }
}
