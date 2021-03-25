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
    
    private let mboumToken = "M5VTjpNUTaMyYISvj7ScDjgPEx2QREZIuNNyIogUBjO0JlVzazEZiGuUWDEd"
    private let mboumTrendUrlString = "https://mboum.com/api/v1/co/collections/?list=most_actives&start=1&apikey="
   
    private let iexapisToken = "token=pk_2b9abbcc4e2d4f3188ec43a577ad3651"
    private let iexapisTrendUrlString = "https://cloud.iexapis.com/stable/stock/market/collection/list?collectionName=mostactive"
    
    func getStocksTrend(completion: @escaping (Result<[Stock], StocksManagerError>) -> Void) {
        
        let url = URL(string: "\(mboumTrendUrlString)\(mboumToken)")
        let request = Request(url: url, parser: MobiumParser())
        
        networkManager.makeRequest(request) { (result) in
            switch result {
            case .failure:
                completion(.failure(.error))
            case .success(let data):
                completion(.success(data))
            }
        }
    }
}

enum StocksManagerError: Error {
    case error
}
