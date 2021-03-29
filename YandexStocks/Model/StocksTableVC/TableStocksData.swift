//
//  TableStocks.swift
//  YandexStocks
//
//  Created by Admin on 3/26/21.
//

import Foundation

class TableStocksData {
    // MARK: - Dependencies
    private let stocksManager = StocksManager()
    
    var asyncUpdateData: (() -> Void)?
    var fetchingDataCallback: ((Bool) -> Void)?
    var stockPriceUpdateCallback: ((String, Double) -> Void)?
    
    var currentVisibleStocks = [Stock]()
    var searchResultStocks = [Stock]()
    var isSearch: Bool = false
    var trendStocks = [Stock]() {
        didSet {
            //checkFavourite()
        }
    }
    var favouriteStocks = [Stock]() {
        didSet {
            //checkFavourite()
        }
    }
    
    private var currentVisibleData: StockSegments = .trend
    
    // MARK: - Public
    func changeFavourite(_ cell: StockTableViewCell) {
        if favouriteStocks.contains(where: { $0.ticker.uppercased() == cell.stockTicker?.uppercased()}),
           let stockForRemove = favouriteStocks.filter({ $0.ticker.uppercased() == cell.stockTicker?.uppercased()}).first {
            cell.isFavourite = false
            stocksManager.removeFavouriteStock(stockForRemove)
            (trendStocks.first { $0.ticker.uppercased() == cell.stockTicker?.uppercased()})?.isFavourite = false
            favouriteStocks = favouriteStocks.filter { $0.ticker.uppercased() != cell.stockTicker?.uppercased() }
            if currentVisibleData == .favourite {
                currentVisibleStocks = favouriteStocks
                asyncUpdateData?()
            }
        } else {
            if let stockForAdd = trendStocks.filter({ $0.ticker.uppercased() == cell.stockTicker?.uppercased()}).first {
                cell.isFavourite = true
                stocksManager.addFavouriteStock(stockForAdd)
                favouriteStocks.append(stockForAdd)
                stockForAdd.isFavourite = true
            }
        }
    }
    
    func changeVisibleStocks(_ visibleSegment: StockSegments) {
        currentVisibleData = visibleSegment
        switch visibleSegment {
        case .favourite:
            currentVisibleStocks = favouriteStocks
        case .trend:
            currentVisibleStocks = trendStocks
        }
    }
    
    func search(_ query: String) {
        guard isSearch else {
            switch currentVisibleData {
            case .favourite:
                currentVisibleStocks = favouriteStocks
            case .trend:
                currentVisibleStocks = trendStocks
            }
            asyncUpdateData?()
            return
        }
        
        currentVisibleStocks.removeAll()
        let findedItems = trendStocks.filter {
            $0.ticker.uppercased().contains(query.uppercased()) || $0.name.uppercased().contains(query.uppercased())}
        
        for i in Range(0...4) {
            if i <= findedItems.count - 1 {
                let stock = findedItems[i]
                currentVisibleStocks.append(stock)
            } else {
                break
            }
        }
        asyncUpdateData?()
    }
    
    func getStock(by index: Int) -> Stock? {
        guard index < currentVisibleStocks.count else {
            return nil
        }
        return currentVisibleStocks[index]
    }
    
    func loadData() {
        favouriteStocks = stocksManager.getSavedFavouriteStocks()
        
        stocksManager.getStocksTrend {[weak self] (result) in
            switch result {
            case .failure:
                print("error while fetching stocks")
                self?.fetchingDataCallback?(false)
            case .success(let stocksData):
                self?.trendStocks = stocksData
                self?.checkFavourite()
                self?.currentVisibleStocks = stocksData
                self?.asyncUpdateData?()
                self?.fetchingDataCallback?(true)
                
//                self?.printAddress(address: (self?.favouriteStocks)!)
//                self?.printAddress(address: (self?.trendStocks)!)
//                self?.printAddress(address: (self?.currentVisibleStocks)!)
            }
        }
        
        stocksManager.stockPriceUpdateCallback = {[weak self] (ticker, newPrice) in
            self?.priceUpdated(ticker: ticker, newPrice: newPrice)
        }
    }
    
    // MARK: - Private
    private func checkFavourite() {
        let favSet = Set(favouriteStocks)
        let trendSet = Set(trendStocks)
        let stocksForUpdate = favSet.intersection(trendSet)
        trendStocks.forEach {
            if stocksForUpdate.contains($0) {
                $0.isFavourite = true
            }
        }
    }
    
    private func priceUpdated(ticker: String, newPrice: Double) {
        print("\(ticker) - \(newPrice)")
        guard let cellForUpdate = favouriteStocks.first(where: { $0.ticker == ticker}) else {
            print("Cant find stock for update")
            return
        }
        cellForUpdate.updatePrice(newPrice: newPrice)
        stocksManager.updateFavouriteStock(cellForUpdate)
        if currentVisibleData == .favourite {
            asyncUpdateData?()
        }
    }
    
//    private func printAddress(address o: UnsafeRawPointer ) {
//        print(String(format: "%p", Int(bitPattern: o)))
//    }
}
