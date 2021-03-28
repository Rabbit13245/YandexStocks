//
//  News.swift
//  YandexStocks
//
//  Created by Дмитрий Зайцев on 28.03.2021.
//

import Foundation

struct News: Codable {
    var headline: String
    var source: String
    var datetime: Int
    var imageUrlString: String
    var newsUrlString: String
}
