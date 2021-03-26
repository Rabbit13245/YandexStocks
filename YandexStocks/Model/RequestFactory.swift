//
//  RequestFactory.swift
//  YandexStocks
//
//  Created by Admin on 3/25/21.
//

import Foundation


class RequestFactory {
    private static let mboumToken = "M5VTjpNUTaMyYISvj7ScDjgPEx2QREZIuNNyIogUBjO0JlVzazEZiGuUWDEd"
    private static let mboumTrendUrlString = "https://mboum.com/api/v1/co/collections/?list=most_actives&start=1&apikey="
   
    private static let iexapisToken = "token=pk_2b9abbcc4e2d4f3188ec43a577ad3651"
    private static let iexapisTrendUrlString = "https://cloud.iexapis.com/stable/stock/market/collection/list?collectionName=mostactive"
    
    private static let finnhubToken = "c1ct6j748v6p6471mia0"
    private static let finhubAllStocksUrlString = "https://finnhub.io/api/v1/stock/symbol?exchange=US&token="
    private static let finhubPricesUrlString = "https://finnhub.io/api/v1/quote?symbol="
    private static let finhubLogoUrlString = "https://finnhub.io/api/v1/stock/profile2?symbol="
    static func getTrendStocksRequest() -> Request<MobiumParser>? {
        let url = URL(string: "\(mboumTrendUrlString)\(mboumToken)")
        return Request(url: url, parser: MobiumParser())
    }
    
    static func getAllStocksRequest() -> Request<FinnhubStocksParser>? {
        let url = URL(string: "\(finhubAllStocksUrlString)\(finnhubToken)")
        return Request(url: url, parser: FinnhubStocksParser())
    }
    
    static func getPricesRequest(for ticker: String) -> Request<FinnhubPriceParser>? {
        let url = URL(string: "\(finhubPricesUrlString)\(ticker)&token=\(finnhubToken)")
        return Request(url: url, parser: FinnhubPriceParser())
    }

    static func getLogoRequest(for ticker: String) -> Request<FinnhubLogoParser>? {
        let url = URL(string: "\(finhubLogoUrlString)\(ticker)&token=\(finnhubToken)")
        return Request(url: url, parser: FinnhubLogoParser())
    }
    
    static func getFakeTrendStocksRequest() -> Request<MobiumParser>? {
        guard let url = Bundle.main.url(forResource: "trendStocks", withExtension: "json") else {
            return nil
        }
        
        return Request(url: url, parser: MobiumParser())
    }
}
