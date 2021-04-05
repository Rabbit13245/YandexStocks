//
//  StocksTableViewDelegate.swift
//  YandexStocks
//
//  Created by Admin on 3/23/21.
//

import UIKit

class StocksTableViewDelegate: NSObject, UITableViewDelegate {

    weak var delegate: ISuggestedSearch?
    var stocksData: TableStocksData?
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let stocksData = stocksData,
              let stock = stocksData.getStock(by: indexPath.row) else { return }
        delegate?.didSelectStock(stock: stock)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
