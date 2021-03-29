//
//  Request.swift
//  YandexStocks
//
//  Created by Admin on 3/29/21.
//

import Foundation

struct Request<Parser>: IRequest where Parser: IParser {
    var url: URL?
    var parser: Parser
}
