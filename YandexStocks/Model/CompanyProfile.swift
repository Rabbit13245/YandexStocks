//
//  CompanyProfile.swift
//  YandexStocks
//
//  Created by Дмитрий Зайцев on 28.03.2021.
//

import Foundation

struct CompanyProfile {
    var country: String
    var currency: String
    var exchange: String
    var marketCapitalization: Int
    var weburl: String
    var phone: String
    
    var array: [(String, String)] {
        var ar = [(String, String)]()
        ar.append(("Country", country))
        ar.append(("Currency", currency))
        ar.append(("Exchange", exchange))
        ar.append(("Capitalization", String(marketCapitalization)))
        ar.append(("Phone", phone))
        ar.append(("Web", weburl))
        return ar
    }
}
