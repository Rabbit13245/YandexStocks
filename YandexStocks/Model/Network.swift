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

class DataParser: IParser {
    func parse(data: Data) -> Data? {
        return data
    }
}

class BaseCodableParser<Model>: IParser where Model: Decodable {
    func parse(data: Data) -> Model? {
        return try? JSONDecoder().decode(Model.self, from: data)
    }
}

protocol IRequest {
    associatedtype Parser: IParser
    
    var httpMethod: HTTPMethod { get }
    var url: URL? { get }
    var data: Data? { get }
    var contentType: String? { get }
    var parser: Parser { get }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

struct Request<Parser>: IRequest where Parser: IParser {
    let httpMethod: HTTPMethod
    let url: URL?
    let parser: Parser
    let data: Data?
    let contentType: String?
    
    init(httpMethod: HTTPMethod,
         url: URL?,
         parser: Parser,
         data: Data? = nil,
         contentType: String? = nil) {
        self.httpMethod = httpMethod
        self.url = url
        self.parser = parser
        self.data = data
        self.contentType = contentType
    }
}


enum NetworkError: Error {
  
  case dateParseError
  case invalidPath
  case parseError
  case requestError
}

protocol INetworkManager {
    func makeRequest<Request>(_ request: Request,
                              session: URLSession,
                              completion: @escaping (Result<Request.Parser.Model, NetworkError>) -> Void) where Request: IRequest
}

class NetworkManager {
    func makeRequest<T: Decodable>(url: URL?,
                                   type: T.Type,
                                   completionHandler: @escaping (Result<T, NetworkError>) -> Void) {
        guard let url = url else {
            return completionHandler(.failure(.invalidPath))
        }
        let request = URLRequest(url: url)
        let dataTask = URLSession.shared.dataTask(with: request) {(data, response, error) in
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 200
            if statusCode != 200 {
                return completionHandler(.failure(.requestError))
            }
            
            guard let jsonData = data,
                  let decodedData = try? JSONDecoder().decode(T.self, from: jsonData) else {
                return completionHandler(.failure(.dateParseError))
            }
            
            return completionHandler(.success(decodedData))
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            dataTask.resume()
        }
    }
}
