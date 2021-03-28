//
//  StocksTableViewDelegate.swift
//  YandexStocks
//
//  Created by Admin on 3/23/21.
//

import UIKit

class StocksTableViewDelegate: NSObject, UITableViewDelegate {
    
    var headerView: UIView?
    var vc: UIViewController?
    var stocksData: TableStocksData?
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = vc,
              let stocksData = stocksData,
              let stock = stocksData.getStock(by: indexPath.row) else { return }
        let stockDataVC = StockDataViewController(stock: stock)
        vc.navigationController?.pushViewController(stockDataVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
