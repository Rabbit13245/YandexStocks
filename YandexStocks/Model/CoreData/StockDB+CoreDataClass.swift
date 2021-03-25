//
//  Stock+CoreDataClass.swift
//  YandexStocks
//
//  Created by Admin on 3/25/21.
//
//

import Foundation
import CoreData

@objc(Stock)
public class StockDB: NSManagedObject {
    convenience init(from model: Stock, in context: NSManagedObjectContext) {
        self.init(context: context)
        
        ticker = model.ticker
        name = model.name
        price = model.price
        isGrowth = model.isGrowth
        change = model.change
    }
}
