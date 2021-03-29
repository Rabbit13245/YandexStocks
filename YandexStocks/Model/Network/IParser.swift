//
//  IParser.swift
//  YandexStocks
//
//  Created by Admin on 3/29/21.
//

import Foundation

protocol IParser {
    associatedtype Model
    func parse(data: Data) -> Model?
}
