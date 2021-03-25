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
    
    func getStocksTrend(completion: @escaping (Result<[Stock], StocksManagerError>) -> Void) {
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
    
    func getSavedFavouriteStocks() -> [Stock] {
        guard let savedFavourite = CoreDataManager.shared.fetchEntities(withName: String(describing: StockDB.self)) as? [StockDB] else {
            return [Stock]()
        }
        return savedFavourite.map {
            Stock(from: $0)
        }
    }
    
    func addFavouriteStock(_ stock: Stock) {
        CoreDataManager.shared.saveInBackground { (context) in
           _ = StockDB(from: stock, in: context)
        }
    }
    
    func removeFavouriteStock() {
        
    }
    
    func updateFavouriteStock() {
        
    }
}

enum StocksManagerError: Error {
    case error
}
