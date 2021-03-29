//
//  DataParser.swift
//  YandexStocks
//
//  Created by Admin on 3/29/21.
//

import Foundation

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
        print("FFFF")
        print(logoResponse.logo)
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
