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

struct FinnhubLogoResponse: Decodable {
    var logo: String
}

