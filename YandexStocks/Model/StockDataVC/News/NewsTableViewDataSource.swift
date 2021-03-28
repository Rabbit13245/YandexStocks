//
//  NewsTableViewDataSource.swift
//  YandexStocks
//
//  Created by Дмитрий Зайцев on 28.03.2021.
//

import UIKit

class NewsTableViewDataSource: NSObject, UITableViewDataSource {
    var newsStockData: NewsStockData?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsStockData?.news.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: StockNewsTableViewCell.self)) as? StockNewsTableViewCell else {
            return UITableViewCell()
        }
        
        guard let model = newsStockData?.news[indexPath.row] else { return cell }
        cell.configure(with: model)
        return cell
    }
}
