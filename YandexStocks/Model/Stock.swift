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
    var isGrowth : Bool?
    var price: Double?
    var change: String?
}

struct mobiumResponce: Decodable {
    var quotes: [mobiumStock]
}

struct mobiumStock: Decodable {
    var symbol: String
    var longName: String
    var regularMarketPrice: Double
    var regularMarketChangePercent: Double
}

