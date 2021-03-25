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
    
    static func getTrendStocksRequest() -> Request<MobiumParser>? {
        let url = URL(string: "\(mboumTrendUrlString)\(mboumToken)")
        return Request(url: url, parser: MobiumParser())
    }
    
    static func getFakeTrendStocksRequest() -> Request<MobiumParser>? {
        guard let url = Bundle.main.url(forResource: "trendStocks", withExtension: "json") else {
            return nil
        }
        
        return Request(url: url, parser: MobiumParser())
    }
}
