//
//  StocksTableViewDataSource.swift
//  YandexStocks
//
//  Created by Admin on 3/23/21.
//

import UIKit

class StocksTableViewDataSource: NSObject, UITableViewDataSource {
    
    var currentVC: StocksViewController?
    var stocksData:TableStocksData?
    var isSearch: Bool = false
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearch {
            return stocksData?.searchResultStocks.count ?? 0
        } else {
            return stocksData?.currentVisibleStocks.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: StockTableViewCell.self)) as? StockTableViewCell else {
            return UITableViewCell()
        }
        
        var model: Stock?
        if isSearch {
            model = stocksData?.searchResultStocks[indexPath.row]
        } else {
            model = stocksData?.currentVisibleStocks[indexPath.row]
        }
        guard let safeModel = model else { return cell }
        if safeModel.logoUrl == nil {
            safeModel.getLogoUrl { (result) in
                if result {
                    DispatchQueue.main.async {
                        cell.configure(with: safeModel)
                    }
                }
            }
        }
        
        cell.configure(with: safeModel)
        cell.odd = indexPath.row % 2 > 0
        
        cell.favouriteButtonPressed = {[weak self] (cell) in
            self?.currentVC?.changeFavourite(cell)
        }
        return cell
    }
}
