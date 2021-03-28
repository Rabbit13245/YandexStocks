//
//  Date+Format.swift
//  YandexStocks
//
//  Created by Дмитрий Зайцев on 28.03.2021.
//

import Foundation

extension Date {
    func convertToString(with format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    static func -(lhs: Date, rhs: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: -rhs, to: lhs)!
    }
    
    func nameOfDay() -> String {
        let weekdays = [
            "SUN",
            "MON",
            "TUE",
            "WED",
            "THU",
            "FRI",
            "SAT"
        ]

        let calendar: Calendar = Calendar.current
        let components = calendar.component(.weekday, from: self)
        return weekdays[components - 1]
    }
}
