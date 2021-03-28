//
//  StockChartData.swift
//  YandexStocks
//
//  Created by Дмитрий Зайцев on 29.03.2021.
//

import Foundation

struct StockChartData {
    var valueGraphData: [Double]
    var rawDescription: [Int]
    var formattedDesctiprion: [String]
    
    mutating func formatDescription(with requestType: ChartsRequestType) {
        formattedDesctiprion = [String]()
        let df = DateFormatter()
        
        for item in rawDescription {
            let dateItem = Date(timeIntervalSince1970: .init(item))
            
            switch requestType {
            case .week:
                formattedDesctiprion.append(dateItem.nameOfDay())
            case .month:
                df.dateFormat = "dd"
                formattedDesctiprion.append(df.string(from: dateItem))
            case.year:
                df.dateFormat = "MMM"
                formattedDesctiprion.append(df.string(from: dateItem))
            }
        }
    }
}
