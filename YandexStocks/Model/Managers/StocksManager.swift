//
//  StocksManager.swift
//  YandexStocks
//
//  Created by Admin on 3/23/21.
//

import Foundation
import Starscream

protocol IStocksManager {
    
}

class StocksManager: IStocksManager {
    var stockPriceUpdateCallback: ((String, Double) -> Void)?
    
    private let networkManager = NetworkManager()
    private var isWebsocketConnected = false
    private var socket: WebSocket?
    
    init() {
        prepareForWebsockets()
        subscribeStock(with: "AAPL")
        
        subscriveBackground()
    }
    
    deinit {
        unsubscribeBackground()
    }
    
    /// Получить трендовые акции для отображения на первой вкладке
    func getStocksTrend(completion: @escaping (Result<[Stock], ManagerError>) -> Void) {
        //getTrendStocksRequest
        guard let request = RequestFactory.getFakeTrendStocksRequest() else {
            completion(.failure(.error))
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.networkManager.makeRequest(request) { (result) in
                switch result {
                case .failure:
                    completion(.failure(.error))
                case .success(let data):
                    completion(.success(data))
                }
            }
        }
        
//        networkManager.makeRequest(request) { (result) in
//            switch result {
//            case .failure:
//                completion(.failure(.error))
//            case .success(let data):
//                completion(.success(data))
//            }
//        }
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
    func getAllStocksForSearch(completion: @escaping (Result<[Stock], ManagerError>) -> Void) {
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
    
    func updateFavouriteStock(_ stock: Stock) {
        let predicate = NSPredicate(format: "ticker == %@", stock.ticker.uppercased())
        CoreDataManager.shared.saveInBackground { (context) in
            guard let stocksForUpdate = CoreDataManager.shared.fetchEntities(
                    withName: String(describing: StockDB.self),
                    withPredicate: predicate,
                context: context) else { return }
            for singleStock in stocksForUpdate {
                singleStock.setValue(stock.change, forKey: "change")
                singleStock.setValue(stock.price, forKey: "price")
                singleStock.setValue(stock.isGrowth, forKey: "isGrowth")
            }
        }
    }
    
    func subscribeStock(with ticker: String) {
        socket?.write(string: "{'type':'subscribe','symbol':'\(ticker)'}")
    }
    
    func unsubscribeStock(with ticker: String) {
        socket?.write(string: "{'type':'unsubscribe','symbol':'\(ticker)'}")
    }
    
    // MARK: - Private
    private func prepareForWebsockets() {
        guard let url = RequestFactory.getFinnhubWebsocketAddress() else { return }
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket?.delegate = self
        socket?.connect()
    }
    
    private func subscriveBackground() {
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    private func unsubscribeBackground() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc private func appMovedToForeground() {
        guard let socket = socket else {
            print("Socker error")
            return
        }
        if !isWebsocketConnected {
            socket.connect()
        }
    }
}

extension StocksManager: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            isWebsocketConnected = true
            print("websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            isWebsocketConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            print("Received text: \(string)")
            stockPriceUpdateCallback?("AAPL", Double(Int.random(in: 150..<250)))
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping:
            break
        case .pong:
            break
        case .viabilityChanged:
            break
        case .reconnectSuggested:
            break
        case .cancelled:
            isWebsocketConnected = false
        case .error(let error):
            isWebsocketConnected = false
            print("ERROR WEBSOCKET!!! \(String(describing: error))")
        }
    }
}
enum ManagerError: Error {
    case error
}
