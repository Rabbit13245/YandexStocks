//
//  TableStocks.swift
//  YandexStocks
//
//  Created by Admin on 3/26/21.
//

import Foundation

class TableStocksData {
    
    var asyncUpdateData: (() -> Void)?
    // MARK: - Dependencies
    private let stocksManager = StocksManager()
    
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
    
    // MARK: - Initializers
    init() {
        loadData()
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
    
    // MARK: - Private
    private func loadData() {
        favouriteStocks = stocksManager.getSavedFavouriteStocks()
        
        stocksManager.getStocksTrend {[weak self] (result) in
            switch result {
            case .failure:
                print("error while fetching stocks")
            case .success(let stocksData):
                self?.trendStocks = stocksData
                self?.checkFavourite()
                self?.currentVisibleStocks = stocksData
                self?.asyncUpdateData?()
            }
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
    }
}
