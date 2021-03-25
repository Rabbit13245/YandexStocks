//
//  StocksTableViewDataSource.swift
//  YandexStocks
//
//  Created by Admin on 3/23/21.
//

import UIKit

class StocksTableViewDataSource: NSObject, UITableViewDataSource {
    
    var showingStocks = [Stock]()
    var stocks = [Stock]()
    var favouritreStocks = [Stock]()
    
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
                self?.showingStocks = stocksData
                self?.asyncUpdateData?()
            }
        }
        
        favouritreStocks = stocksManager.getSavedFavouriteStocks()
    }
    
    func changeView(_ indexView: Int) {
        showingStocks = indexView == 0 ? stocks : favouritreStocks
        asyncUpdateData?()
    }
    
    func configure(asyncUpdateDataCallback: @escaping ()->Void) {
        self.asyncUpdateData = asyncUpdateDataCallback
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showingStocks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StockTableViewCell.identifier) as? StockTableViewCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: showingStocks[indexPath.row])
        cell.odd = indexPath.row % 2 > 0
        
        cell.favouriteButtonPressed = {[weak self] (cell) in
            self?.changeFavourite(cell)
        }
        return cell
    }
    
    // MARK: - Private
    private func changeFavourite(_ cell: StockTableViewCell) {
        //favoriteStocksArray.contains(where: {$0.ticker == stock.ticker })
        if favouritreStocks.contains(where: { $0.ticker.uppercased() == cell.ticker.text?.uppercased()}) {
            cell.isFavourite = false
            favouritreStocks = favouritreStocks.filter { $0.ticker.uppercased() != cell.ticker.text?.uppercased() }
        } else {
            if let model = cell.model {
                favouritreStocks.append(model)
            }
            cell.isFavourite = true
        }
    }
}
