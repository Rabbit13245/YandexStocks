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
    private var tickersForAdd = Set<String>()
    
    init(configureWebSocket: Bool = false) {
        if configureWebSocket {
            prepareForWebsockets()
            subscriveForeground()
        }
    }
    
    deinit {
        unsubscribeForeground()
        socket?.disconnect()
    }
    
    /// Получить трендовые акции для отображения на первой вкладке
    func getStocksTrend(completion: @escaping (Result<[Stock], ManagerError>) -> Void) {
        //getFakeTrendStocksRequest
        guard let request = RequestFactory.getIexapisTrendStocksRequest() else {
            completion(.failure(.error))
            return
        }
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            self.networkManager.makeRequest(request) { (result) in
//                switch result {
//                case .failure:
//                    completion(.failure(.error))
//                case .success(let data):
//                    completion(.success(data))
//                }
//            }
//        }
        
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
            tickersForAdd.insert(stock.ticker)
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
            case .failure(let err):
                print("error getAllStocksForSearch \(err)")
                completion(.failure(.error))
            case .success(let data):
                completion(.success(data))
            }
        }
    }
    
    func searchStocks(query: String,
                      completion: @escaping (Result<[Stock], ManagerError>) -> Void) {
        guard let request = RequestFactory.getFinancialSearchReqeust(for: query) else {
            completion(.failure(.error))
            return
        }
        
        networkManager.makeCancelableRequest(request) { (result) in
            switch result {
            case .failure(let err):
                print("search error: \(err)")
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
                print("requset:\(String(describing: request.url)) error: \(f)")
                completion(.failure(.error))
            case .success(let data):
                completion(.success(data))
            }
        }
    }
    
    /// Добавить избранную акцию в кордату
    func addFavouriteStock(_ stock: Stock) {
        subscribeStock(with: stock.ticker)
        CoreDataManager.shared.saveInBackground { (context) in
           _ = StockDB(from: stock, in: context)
        }
    }
    
    /// Удалить избранную акцию из кордаты
    func removeFavouriteStock(_ stock: Stock) {
        unsubscribeStock(with: stock.ticker, needRemove: true)
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
        let text = "{\"type\":\"subscribe\",\"symbol\":\"\(ticker)\"}"
        print(text)
        
        tickersForAdd.insert(ticker)
        if isWebsocketConnected {
            socket?.connect()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.socket?.write(string: text)
            }
        } else {
            socket?.write(string: text)
        }
    }
    
    func unsubscribeStock(with ticker: String, needRemove: Bool = false) {
        if needRemove {
            if tickersForAdd.contains(ticker) {
                tickersForAdd.remove(ticker)
            }
        }
        let text = "{\"type\":\"unsubscribe\",\"symbol\":\"\(ticker)\"}"
        print(text)
        socket?.write(string: text)
//        if isWebsocketConnected {
//            socket?.connect()
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                self.socket?.write(string: "{\"type\":\"unsubscribe\",\"symbol\":\"\(ticker)\"}")
//            }
//        } else {
//            socket?.write(string: "{\"type\":\"unsubscribe\",\"symbol\":\"\(ticker)\"}")
//        }
    }
    
    // MARK: - Private
    private func prepareForWebsockets() {
        guard let url = RequestFactory.getFinnhubWebsocketAddress() else { return }
        var request = URLRequest(url: url)
        let pinner = FoundationSecurity(allowSelfSigned: true)
        request.timeoutInterval = 5
        socket = WebSocket(request: request, certPinner: pinner)
        socket?.delegate = self
        socket?.connect()
    }
    
    private func subscriveForeground() {
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    private func unsubscribeForeground() {
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
        print(tickersForAdd.count)
    }
    
    @objc private func appMovedToBackground() {
        for item in self.tickersForAdd {
            unsubscribeStock(with: item) // бывают моменты когда тупит и надо отписаться
        }
        socket?.disconnect()
        print("disconnect")
    }
}

extension StocksManager: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            isWebsocketConnected = true
            print("websocket is connected: \(headers)")
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                for item in self.tickersForAdd {
//                    self.unsubscribeStock(with: item) // бывают моменты когда тупит и надо отписаться
//                }
//            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                for item in self.tickersForAdd {
                    self.subscribeStock(with: item) // бывают моменты когда тупит и надо отписаться
                }
            }

        case .disconnected(let reason, let code):
            isWebsocketConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
//            print("Received text: \(string)")
            guard let data = try? JSONDecoder().decode(FinnhubWebsocketResponse.self, from: Data(string.utf8)),
                  let price = data.data.first?.p,
                  let ticker = data.data.first?.s else {
                print("error while decoding websocket answer")
                return
            }
            stockPriceUpdateCallback?(ticker, price)
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping:
            print("ping")
        case .pong:
            print("pong")
        case .viabilityChanged:
            print("viabilityChanged")
        case .reconnectSuggested:
            print("reconnectSuggested")
        case .cancelled:
            isWebsocketConnected = false
        case .error(let error):
            isWebsocketConnected = false
            print("ERROR WEBSOCKET!!! \(String(describing: error))")
//            NotificationCenter.default.post(name: Notification.Name("WebsocketsError"), object: nil)
        }
    }
}
enum ManagerError: Error {
    case error
}
