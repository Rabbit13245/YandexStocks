//
//  IRequest.swift
//  YandexStocks
//
//  Created by Admin on 3/29/21.
//

import Foundation

protocol IRequest {
    associatedtype Parser: IParser
    
    var url: URL? { get }
    var parser: Parser { get }
}
