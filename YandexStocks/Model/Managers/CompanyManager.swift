//
//  StockNewsManager.swift
//  YandexStocks
//
//  Created by Дмитрий Зайцев on 28.03.2021.
//

import Foundation

class CompanyManager {
    private var networkManager = NetworkManager()
    
    /// Получить новости по компании
    func getNews(ticker: String, from: String, to: String, completion: @escaping (Result<[News], ManagerError>) -> Void) {
        guard let request = RequestFactory.getNewsRequest(for: ticker, from: from, to: to) else {
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
    
    func getCompanyInfo(ticker: String, completion: @escaping (Result<CompanyProfile, ManagerError>) -> Void) {
        guard let request = RequestFactory.getCompanyProfileRequest(for: ticker) else {
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
    
    func getChartData(ticker: String,
                      res: String,
                      from: String,
                      to: String,
                      completion: @escaping (Result<StockChartData, ManagerError>) -> Void) {
        
        guard let request = RequestFactory.getStockChartDataRequest(for: ticker,
                                                                    res: res,
                                                                    from: from,
                                                                    to: to) else {
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
}
