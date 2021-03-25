//
//  Stock.swift
//  YandexStocks
//
//  Created by Admin on 3/23/21.
//

import Foundation

struct Stock {
    var ticker: String
    var name: String
    var isGrowth: Bool
    var price: Double
    var change: String
    
    init(from model: StockDB) {
        ticker = model.ticker
        name = model.name
        isGrowth = model.isGrowth
        price = model.price
        change = model.change
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
}

struct mobiumResponce: Decodable {
    var quotes: [mobiumStock]
}

struct mobiumStock: Decodable {
    var symbol: String
    var longName: String
    var regularMarketPrice: Double
    var regularMarketChangePercent: Double
    var regularMarketChange: Double
}

