//
//  StocksManager.swift
//  YandexStocks
//
//  Created by Admin on 3/23/21.
//

import Foundation

protocol IStocksManager {
    
}

class StocksManager: IStocksManager {
    private var networkManager = NetworkManager()
    
    /// Получить трендовые акции для отображения на первой вкладке
    func getStocksTrend(completion: @escaping (Result<[Stock], ManagerError>) -> Void) {
        //getTrendStocksRequest
        guard let request = RequestFactory.getFakeTrendStocksRequest() else {
            completion(.failure(.error))
            return
        }
        
        networkManager.makeRequest(request) { (result) in
            switch result {
            case .failure:
                completion(.failure(.error))
            case .success(let data):
                completion(.success(data))
            }
        }
    }
    
    /// Получить сохраненные избранные акции для второй вкладки
    func getSavedFavouriteStocks() -> [Stock] {
        guard let savedFavourite = CoreDataManager.shared.fetchEntities(withName: String(describing: StockDB.self)) as? [StockDB] else {
            return [Stock]()
        }
        return savedFavourite.map {
            let stock = Stock(from: $0)
            stock.isFavourite = true
            stock.getData()
            return stock
        }
    }
    
    /// Получить массив всех акций для поиска
    func getAllStocksForSearch(completion: @escaping (Result<[Stock], ManagerError>) -> Void) -> Void {
        guard let request = RequestFactory.getAllStocksRequest() else {
            completion(.failure(.error))
            return
        }
        
        networkManager.makeRequest(request) { (result) in
            switch result {
            case .failure:
                completion(.failure(.error))
            case .success(let data):
                completion(.success(data))
            }
        }
    }
    
    /// Обновить цены по акции
    func getPrices(for ticker: String, completion: @escaping (Result<(Double, Double)?, ManagerError>) -> Void) {
        guard let request = RequestFactory.getPricesRequest(for: ticker) else {
            completion(.failure(.error))
            return
        }
        
        networkManager.makeRequest(request) { (result) in
            switch result {
            case .failure:
                completion(.failure(.error))
            case .success(let data):
                completion(.success(data))
            }
        }
    }
    
    /// Получить лого акции
    func getLogoUrl(for ticker: String, completion: @escaping (Result<String?, ManagerError>) -> Void) {
        guard let request = RequestFactory.getLogoRequest(for: ticker) else {
            completion(.failure(.error))
            return
        }
        
        networkManager.makeRequest(request) { (result) in
            switch result {
            case .failure(let f):
                print(f)
                completion(.failure(.error))
            case .success(let data):
                completion(.success(data))
            }
        }
    }
    
    /// Добавить избранную акцию в кордату
    func addFavouriteStock(_ stock: Stock) {
        CoreDataManager.shared.saveInBackground { (context) in
           _ = StockDB(from: stock, in: context)
        }
    }
    
    /// Удалить избранную акцию из кордаты
    func removeFavouriteStock(_ stock: Stock) {
        let predicate = NSPredicate(format: "ticker == %@", stock.ticker.uppercased())
        guard let stocksForRemove = CoreDataManager.shared.fetchEntities(withName: String(describing: StockDB.self), withPredicate: predicate)
        else { return }
        
        for stock in stocksForRemove {
            CoreDataManager.shared.removeObject(stock)
        }
    }
}

enum ManagerError: Error {
    case error
}
