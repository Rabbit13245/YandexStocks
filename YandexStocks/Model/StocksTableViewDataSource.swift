//
//  StocksTableViewDataSource.swift
//  YandexStocks
//
//  Created by Admin on 3/23/21.
//

import UIKit

class StocksTableViewDataSource: NSObject, UITableViewDataSource {
    
    var stocks = [Stock]()
//    var stocks = [
//        Stock(ticker: "YNDX", name: "Yandex"),
//        Stock(ticker: "AAPL", name: "Apple inc"),
//        Stock(ticker: "GOOGL", name: "Alphabet Class A"),
//        Stock(ticker: "AMZN", name: "Amazon com"),
//        Stock(ticker: "BAC", name: "Bank of America Corp"),
//        Stock(ticker: "MSFT", name: "Microsoft Corporation"),
//        Stock(ticker: "VRLNGT", name: "Some company with long name"),
//    ]
    
    private let stocksManager = StocksManager()
     var asyncUpdateData: (()->Void)?
    
    override init() {
        super.init()
        
        stocksManager.getStocksTrend {[weak self] (result) in
            switch result {
            case .failure:
                print("error while fetching stocks")
            case .success(let stocksData):
                self?.stocks = stocksData
                self?.asyncUpdateData?()
            }
        }
    }
    
    func configure(asyncUpdateDataCallback: @escaping ()->Void) {
        self.asyncUpdateData = asyncUpdateDataCallback
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stocks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StockTableViewCell.identifier) as? StockTableViewCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: stocks[indexPath.row])
        cell.odd = indexPath.row % 2 > 0
        return cell
    }
}
