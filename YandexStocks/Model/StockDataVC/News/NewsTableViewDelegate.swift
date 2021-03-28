//
//  NewsTableViewDelegate.swift
//  YandexStocks
//
//  Created by Дмитрий Зайцев on 28.03.2021.
//

import UIKit

class NewsTableViewDelegate: NSObject, UITableViewDelegate {
    var newsStockData: NewsStockData?
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 360
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let urlString = newsStockData?.news[indexPath.row].newsUrlString,
            let url = URL(string: urlString) else {
            return
        }
        UIApplication.shared.open(url)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
