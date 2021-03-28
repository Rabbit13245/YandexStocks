//
//  CompanySummaryData.swift
//  YandexStocks
//
//  Created by Дмитрий Зайцев on 28.03.2021.
//

import Foundation

class CompanyProfileData {
    // MARK: - Public
    var asyncUpdateData: (() -> Void)?
    var companyProfile = [(String, String)]() {
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
        companyManager.getCompanyInfo(ticker: ticker) { [weak self] (result) in
            switch result {
            case .failure:
                print("error while fetching news")
            case .success(let data):
                self?.companyProfile = data.array
            }
        }
    }
}
