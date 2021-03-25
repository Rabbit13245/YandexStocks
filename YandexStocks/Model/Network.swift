//
//  Network.swift
//  YandexStocks
//
//  Created by Admin on 3/23/21.
//

import Foundation

protocol IParser {
    associatedtype Model
    func parse(data: Data) -> Model?
}

class DataParser<Model>: IParser where Model: Decodable {
    func parse(data: Data) -> Model? {
        return try? JSONDecoder().decode(Model.self, from: data)
    }
}

class MobiumParser: IParser {
    typealias Model = [Stock]
    
    func parse(data: Data) -> [Stock]? {
        guard let mobiumResponce = try? JSONDecoder().decode(mobiumResponce.self, from: data) else {
            return nil
        }

        return mobiumResponce.quotes.map {
            let isGrowth = $0.regularMarketChangePercent > 0
            var change = String(format: ".2f", $0.regularMarketChangePercent) + "%"
            if isGrowth {
                change = "+" + change
            }
            return Stock(ticker: $0.symbol,
                         name: $0.longName,
                         isGrowth: $0.regularMarketChangePercent > 0,
                         price: $0.regularMarketPrice,
                         change: change)
        }
    }
}

protocol IRequest {
    associatedtype Parser: IParser
    
    var url: URL? { get }
    var parser: Parser { get }
}

struct Request<Parser>: IRequest where Parser: IParser {
    var url: URL?
    var parser: Parser
}

enum NetworkError: Error {
  case dateParseError
  case invalidPath
  case parseError
  case requestError
}

class NetworkManager {
    func makeRequest<Request>(_ request: Request,
                              completionHandler: @escaping (Result<Request.Parser.Model, NetworkError>) -> Void) where Request: IRequest {
        guard let url = request.url else {
            return completionHandler(.failure(.invalidPath))
        }
        let urlRequest = URLRequest(url: url)
        let dataTask = URLSession.shared.dataTask(with: urlRequest) {(data, response, error) in
            
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 200
            
            if statusCode != 200 {
                return completionHandler(.failure(.requestError))
            }
            
            guard let data = data, error == nil else {
                return completionHandler(.failure(.requestError))
            }
            
            guard let result = request.parser.parse(data: data) else {
                return completionHandler(.failure(.parseError))
            }
            
            return completionHandler(.success(result))
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            dataTask.resume()
        }
    }
}
