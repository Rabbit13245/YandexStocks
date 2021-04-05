//
//  TableStocks.swift
//  YandexStocks
//
//  Created by Admin on 3/26/21.
//

import Foundation

class TableStocksData {
    // MARK: - Dependencies
    private let stocksManager = StocksManager(configureWebSocket: true)
    
    var asyncUpdateData: (() -> Void)?
    var asyncSearchUpdateData: (() -> Void)?
    var fetchingDataCallback: ((Bool) -> Void)?
    var stockPriceUpdateCallback: ((String, Double) -> Void)?
    
    var currentVisibleStocks: [Stock] {
        switch currentVisibleData {
        case .trend:
            return trendStocks
        case .favourite:
            return favouriteStocks
        case .search:
            return searchResultStocks
        }
    }
    var searchResultStocks = [Stock]()
    var trendStocks = [Stock]()
    var favouriteStocks = [Stock]()
    var fullStocks = [Stock]()
    
    private var currentVisibleData: StockSegments = .trend {
        didSet {
            asyncUpdateData?()
        }
    }
    
    init() {
        configure()
    }
    
    // MARK: - Public
    func changeFavourite(_ cell: StockTableViewCell) {
        if favouriteStocks.contains(where: { $0.ticker.uppercased() == cell.stockTicker?.uppercased()}),
           let stockForRemove = favouriteStocks.filter({ $0.ticker.uppercased() == cell.stockTicker?.uppercased()}).first {
            cell.isFavourite = false
            stocksManager.removeFavouriteStock(stockForRemove)
            (trendStocks.first { $0.ticker.uppercased() == cell.stockTicker?.uppercased()})?.isFavourite = false
            favouriteStocks = favouriteStocks.filter { $0.ticker.uppercased() != cell.stockTicker?.uppercased() }
            if currentVisibleData == .favourite {
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
    }
    
    func search(_ query: String) {
        guard currentVisibleData == .search else {
            asyncUpdateData?()
            return
        }
        
        searchResultStocks.removeAll()
        
//        stocksManager.searchStocks(query: query) { [weak self] (result) in
//            switch result {
//            case .failure:
//                print("error while searching stocks")
//            case .success(let data):
//                print("\(query): \(data.count)")
//                data.forEach {
//                    self?.searchResultStocks.append($0)
//                }
//            }
//            self?.asyncSearchUpdateData?()
//        }
        
        searchResultStocks.removeAll()
        let findedItems: [Stock]
        if fullStocks.count == 0 {
            findedItems = trendStocks.filter {
                $0.ticker.uppercased().contains(query.uppercased()) || $0.name.uppercased().contains(query.uppercased())}
        } else {
            findedItems = fullStocks.filter {
                $0.ticker.uppercased().contains(query.uppercased()) || $0.name.uppercased().contains(query.uppercased())}
        }

        for i in Range(0...4) {
            if i <= findedItems.count - 1 {
                let stock = findedItems[i]
                searchResultStocks.append(stock)
            } else {
                break
            }
        }
        asyncSearchUpdateData?()
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
                self?.asyncUpdateData?()
                self?.fetchingDataCallback?(true)
                
//                self?.printAddress(address: (self?.favouriteStocks)!)
//                self?.printAddress(address: (self?.trendStocks)!)
//                self?.printAddress(address: (self?.currentVisibleStocks)!)
            }
        }
        
//        stocksManager.getAllStocksForSearch { [weak self] (result) in
//            switch result {
//            case .failure:
//                print("error while fetching full list of stocks")
//            case .success(let stocks):
//                self?.fullStocks = stocks
//            }
//        }
    }
    
    // MARK: - Private
    private func configure() {
        stocksManager.stockPriceUpdateCallback = {[weak self] (ticker, newPrice) in
            self?.priceUpdated(ticker: ticker, newPrice: newPrice)
        }
    }
    
    private func checkFavourite() {
        let favSet = Set(favouriteStocks)
        let trendSet = Set(trendStocks)
        let stocksForUpdate = favSet.intersection(trendSet)
        trendStocks.forEach {
            if stocksForUpdate.contains($0) {
                $0.isFavourite = true
            }
        }
        
        trendStocks.forEach { (stock) in
            if stocksForUpdate.contains(stock) {
                stock.logoUrl = stocksForUpdate.first { $0.ticker == stock.ticker }?.logoUrl
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
