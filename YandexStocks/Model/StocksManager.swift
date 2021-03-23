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
    
    private let baseUrl = "https://pixabay.com/api/"
    private var apiKey: String? {
            Bundle.main.object(forInfoDictionaryKey: "PixabayAPIKey") as? String
        }
    
    func getStocksTrend(completion: @escaping (Result<Stock, StocksManagerError>) -> Void) {
        let url = URL(string: baseUrl)
        
        networkManager.makeRequest(url: url, type: Stock.self) { (result) in
            switch result {
            case .failure:
                completion(.failure(.error))
            case .success(let model):
                completion(.success(model))
            }
        }
    }
}

enum StocksManagerError: Error {
    case error
}
