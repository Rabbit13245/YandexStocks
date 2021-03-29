//
//  Stock+CoreDataProperties.swift
//  YandexStocks
//
//  Created by Admin on 3/25/21.
//
//

import Foundation
import CoreData

extension StockDB {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StockDB> {
        return NSFetchRequest<StockDB>(entityName: "Stock")
    }

    @NSManaged public var ticker: String
    @NSManaged public var name: String
    @NSManaged public var price: Double
    @NSManaged public var change: String
    @NSManaged public var isGrowth: Bool
    @NSManaged public var logoUrl: String?
}
