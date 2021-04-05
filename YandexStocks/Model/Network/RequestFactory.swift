//
//  RequestFactory.swift
//  YandexStocks
//
//  Created by Admin on 3/25/21.
//

import Foundation

class RequestFactory {
    private static let mboumToken = "yYJvQtsAIR9Dt894Ztg6mfAyt4OHVKQhnJdVzsosTzPTUx98XFPLeGxUzHnQ"
    private static let mboumTrendUrlString = "https://mboum.com/api/v1/co/collections/?list=most_actives&start=1&apikey="

    private static let iexapisToken = "&token=pk_2b9abbcc4e2d4f3188ec43a577ad3651"
    private static let iexapisTrendUrlString = "https://cloud.iexapis.com/stable/stock/market/list/mostactive?listLimit=20"
    
    private static let finnhubToken = "c1ct6j748v6p6471mia0"
    private static let finnhubAllStocksUrlString = "https://finnhub.io/api/v1/stock/symbol?exchange=US&token="
    private static let finnhubPricesUrlString = "https://finnhub.io/api/v1/quote?symbol="
    private static let finnhubCompanyProfileUrlString = "https://finnhub.io/api/v1/stock/profile2?symbol="
    private static let finnhubNewsUrlString = "https://finnhub.io/api/v1/company-news?symbol="
    private static let finnhubChartUrlString = "https://finnhub.io/api/v1/stock/candle?symbol="
    private static let finnhubSearchUrlString = "https://finnhub.io/api/v1/search?q="
    private static let finnhubWebsockerUrlString = "wss://ws.finnhub.io?token="
    
    private static let financialToken = "b238b1c1757ac80b007ea80f252502fa"
    private static let financialSearchUrlString = "https://financialmodelingprep.com/api/v3/search?query="
    private static let financialTrendUrlString = "https://financialmodelingprep.com/api/v3/available-traded/list?apikey="
    
    static func getTrendStocksRequest() -> Request<MobiumParser>? {
        let url = URL(string: "\(mboumTrendUrlString)\(mboumToken)")
        return Request(url: url, parser: MobiumParser())
    }
    
    static func getFinancialTrendRequest() -> Request<FinancialTrendParser>? {
        let url = URL(string: "\(financialTrendUrlString)\(financialToken)")
        return Request(url: url, parser: FinancialTrendParser())
    }
    
    static func getIexapisTrendStocksRequest() -> Request<IexapisTrendParser>? {
        let url = URL(string: "\(iexapisTrendUrlString)\(iexapisToken)")
        return Request(url: url, parser: IexapisTrendParser())
    }
    
    static func getFakeTrendStocksRequest() -> Request<MobiumParser>? {
        guard let url = Bundle.main.url(forResource: "trendStocks", withExtension: "json") else {
            return nil
        }
        
        return Request(url: url, parser: MobiumParser())
    }
    
    static func getAllStocksRequest() -> Request<FinnhubStocksParser>? {
        let url = URL(string: "\(finnhubAllStocksUrlString)\(finnhubToken)")
        return Request(url: url, parser: FinnhubStocksParser())
    }
    
    static func getPricesRequest(for ticker: String) -> Request<FinnhubPriceParser>? {
        let url = URL(string: "\(finnhubPricesUrlString)\(ticker)&token=\(finnhubToken)")
        return Request(url: url, parser: FinnhubPriceParser())
    }

    static func getLogoRequest(for ticker: String) -> Request<FinnhubLogoParser>? {
        let url = URL(string: "\(finnhubCompanyProfileUrlString)\(ticker)&token=\(finnhubToken)")
        return Request(url: url, parser: FinnhubLogoParser())
    }
    
    static func getNewsRequest(for ticker: String, from: String, to: String) -> Request<FinnhubNewsParser>? {
        let url = URL(string: "\(finnhubNewsUrlString)\(ticker)&from=\(from)&to=\(to)&token=\(finnhubToken)")
        return Request(url: url, parser: FinnhubNewsParser())
    }
    
    static func getCompanyProfileRequest(for ticker: String) -> Request<FinnhubCompanyParser>? {
        let url = URL(string: "\(finnhubCompanyProfileUrlString)\(ticker)&token=\(finnhubToken)")
        return Request(url: url, parser: FinnhubCompanyParser())
    }
    
    static func getStockChartDataRequest(for ticker: String,
                                         res: String,
                                         from: String,
                                         to: String) -> Request<FinnhubChartsDataParser>? {
        let url = URL(string: "\(finnhubChartUrlString)\(ticker)&resolution=\(res)&from=\(from)&to=\(to)&token=\(finnhubToken)")
        return Request(url: url, parser: FinnhubChartsDataParser())
    }
    
    static func getFinnhubSearchRequest(for ticker: String) -> Request<FinnhubSearchParser>? {
        let url = URL(string: "\(finnhubSearchUrlString)\(ticker)&token=\(finnhubToken)")
        return Request(url: url, parser: FinnhubSearchParser())
    }
    
    static func getFinancialSearchReqeust(for ticker: String) -> Request<FinancialSearchParser>? {
        let url = URL(string: "\(financialSearchUrlString)\(ticker)&limit=10&exchange=NASDAQ&apikey=\(financialToken)")
        return Request(url: url, parser: FinancialSearchParser())
    }
    
    static func getFinnhubWebsocketAddress() -> URL? {
        guard let url = URL(string: "\(finnhubWebsockerUrlString)\(finnhubToken)") else { return nil }
        return url
    }
}
