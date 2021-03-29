//
//  Stock.swift
//  YandexStocks
//
//  Created by Admin on 3/23/21.
//

import Foundation

class Stock: Hashable {
    
    var updatedLogo: ((String) -> Void)?
    
    var ticker: String
    var name: String
    var isGrowth: Bool
    var price: Double
    var previousPrice: Double?
    var change: String
    var isFavourite: Bool = false
    var logoUrl: String?
    
    static func == (lhs: Stock, rhs: Stock) -> Bool {
        return lhs.ticker.uppercased() == rhs.ticker.uppercased() &&
            lhs.name.uppercased() == rhs.name.uppercased()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ticker)
        hasher.combine(name)
    }
    
    init(from model: StockDB) {
        ticker = model.ticker
        name = model.name
        isGrowth = model.isGrowth
        price = model.price
        change = model.change
        logoUrl = model.logoUrl
    }
    
    init(ticker: String,
         name: String,
         isGrowth: Bool,
         price: Double,
         change: String) {
        self.ticker = ticker
        self.name = name
        self.isGrowth = isGrowth
        self.price = price
        self.change = change
    }
    
    func getLogoUrl(completion: @escaping (Bool) -> Void) {
        let stocksManager = StocksManager()
        stocksManager.getLogoUrl(for: ticker) { [weak self] (result) in
            switch result {
            case .failure:
                self?.logoUrl = nil
                completion(false)
            case .success(let url):
                self?.logoUrl = url
                completion(true)
            }
        }
    }
    
    func getData() {
        let stockManager = StocksManager()
        stockManager.getPrices(for: ticker) {[weak self] (result) in
            switch result {
            case .failure:
                print("Error update price for \(String(describing: self?.ticker))")
            case .success(let data):
                guard let safeData = data else { return }
                self?.price = safeData.0
                self?.previousPrice = safeData.1
                self?.isGrowth = safeData.0 >= safeData.1
                if let change = self?.calculateChange() {
                    self?.change = change
                }
            }
        }
    }
    
    private func calculateChange() -> String {
        guard let previousPrice = previousPrice else { return "" }
        let percent = previousPrice / 100
        var curGrow = price / percent
        if isGrowth {
            curGrow -= 100
            return  "+$\(String(format: "%.2f", price - previousPrice)) (\(String(format: "%.2f", curGrow))%)"
        } else {
            curGrow = 100 - curGrow
            return "-$\(String(format: "%.2f", previousPrice - price)) (\(String(format: "%.2f", curGrow))%)"
        }
    }
}

struct MobiumResponce: Decodable {
    var quotes: [MobiumStock]
}

struct MobiumStock: Decodable {
    var symbol: String
    var longName: String
    var regularMarketPrice: Double
    var regularMarketChangePercent: Double
    var regularMarketChange: Double
}

struct FinnhubCompanyResponse: Decodable {
    var logo: String
    var country: String
    var currency: String
    var exchange: String
    var marketCapitalization: Int
    var weburl: String
    var phone: String
}

struct FinnhubPriceResponse: Decodable {
    var o: Double
    var h: Double
    var l: Double
    var c: Double
    var pc: Double
}

struct FinnhubNewsResponse: Decodable {
    var datetime: Int
    var headline: String
    var image: String
    var source: String
    var url: String
}

struct FinnhubChartDataResponce: Decodable {
    var t: [Int]
    var c: [Double]
}
