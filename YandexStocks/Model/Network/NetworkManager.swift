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
        guard let mobiumResponce = try? JSONDecoder().decode(MobiumResponce.self, from: data) else {
            return nil
        }

        return mobiumResponce.quotes.map {
            let isGrowth = $0.regularMarketChangePercent > 0
            var change = "$\(String(format: "%.2f", abs($0.regularMarketChange))) (\(String(format: "%.2f", abs($0.regularMarketChangePercent)))%)"
            if isGrowth {
                change = "+" + change
            } else {
                change = "-" + change
            }
            return Stock(ticker: $0.symbol,
                         name: $0.longName,
                         isGrowth: $0.regularMarketChangePercent > 0,
                         price: $0.regularMarketPrice,
                         change: change)
        }
    }
}

class FinnhubNewsParser: IParser {
    typealias Model = [News]
    
    func parse(data: Data) -> [News]? {
        guard let news = try? JSONDecoder().decode([FinnhubNewsResponse].self, from: data) else {
            return nil
        }
        return news.map {
            return News(headline: $0.headline,
                        source: $0.source,
                        datetime: $0.datetime,
                        imageUrlString: $0.image,
                        newsUrlString: $0.url)
        }
    }
}

class FinnhubStocksParser: IParser {
    typealias Model = [Stock]
    
    func parse(data: Data) -> [Stock]? {
        return nil
    }
}

class FinnhubPriceParser: IParser {
    typealias Model = (Double, Double)
    
    func parse(data: Data) -> (Double, Double)? {
        guard let priceResponce = try? JSONDecoder().decode(FinnhubPriceResponse.self, from: data) else { return nil }
        return (priceResponce.c, priceResponce.pc)
    }
}

class FinnhubLogoParser: IParser {
    typealias Model = String
    
    func parse(data: Data) -> String? {
        guard let logoResponse = try? JSONDecoder().decode(FinnhubCompanyResponse.self, from: data) else { return nil }
        return logoResponse.logo
    }
}

class FinnhubCompanyParser: IParser {
    typealias Model = CompanyProfile
    
    func parse(data: Data) -> CompanyProfile? {
        guard let response = try? JSONDecoder().decode(FinnhubCompanyResponse.self, from: data) else { return nil }
        
        let phone: String
        if let index = response.phone.firstIndex(of: ".") {
            phone = String(response.phone[...response.phone.index(before: index)])
        } else {
            phone = response.phone
        }
    
        return CompanyProfile(country: response.country,
                              currency: response.currency,
                              exchange: response.exchange,
                              marketCapitalization: response.marketCapitalization,
                              weburl: response.weburl,
                              phone: phone)
    }
}

class FinnhubChartsDataParser: IParser {
    typealias Model = StockChartData
    
    func parse(data: Data) -> StockChartData? {
        guard let response = try? JSONDecoder().decode(FinnhubChartDataResponce.self, from: data) else { return nil }
        return StockChartData(valueGraphData: response.c, rawDescription: response.t, formattedDesctiprion: [String]())
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
