//
//  Network.swift
//  YandexStocks
//
//  Created by Admin on 3/23/21.
//

import Foundation

enum NetworkError: Error {
  case dateParseError
  case invalidPath
  case parseError
  case requestError
}

class NetworkManager {
    
    var cancelableDataTask: URLSessionDataTask?
    
    func makeCancelableRequest<Request>(_ request: Request,
                                        completionHandler: @escaping (Result<Request.Parser.Model, NetworkError>) -> Void) where Request: IRequest {
        guard let url = request.url else {
            return completionHandler(.failure(.invalidPath))
        }
        let urlRequest = URLRequest(url: url)
        
        cancelRequest()
        
        cancelableDataTask = URLSession.shared.dataTask(with: urlRequest) {(data, response, error) in
            
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 200
            
            if statusCode != 200 {
                return completionHandler(.failure(.requestError))
            }
            
            guard let data = data, error == nil else {
                return completionHandler(.failure(.requestError))
            }
            
            guard let result = request.parser.parse(data: data) else {
                print(url)
                return completionHandler(.failure(.parseError))
            }
            
            return completionHandler(.success(result))
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.cancelableDataTask?.resume()
        }
    }
    
    func cancelRequest() {
        cancelableDataTask?.cancel()
    }
    
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
                print(url)
                return completionHandler(.failure(.parseError))
            }
            
            return completionHandler(.success(result))
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            dataTask.resume()
        }
        
    }
}
