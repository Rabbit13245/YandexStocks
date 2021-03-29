//
//  Design.swift
//  YandexStocks
//
//  Created by Admin on 3/23/21.
//

import UIKit

enum Image {
    static let starUnselected = #imageLiteral(resourceName: "star_unselected")
    static let starSelected = #imageLiteral(resourceName: "star_selected")
}

enum Font {
    static let H1 = UIFont.systemFont(ofSize: 28, weight: .bold)
    static let H2 = UIFont.systemFont(ofSize: 18, weight: .bold)
    static let H3 = UIFont.systemFont(ofSize: 16, weight: .semibold)
    static let H4 = UIFont.systemFont(ofSize: 14, weight: .semibold)
    static let Body = UIFont.systemFont(ofSize: 12, weight: .regular)
}

enum Color {
    static let accentGreen = UIColor(red: 36 / 255, green: 178 / 255, blue: 93 / 255, alpha: 1)
    static let accentRed = UIColor(red: 178 / 255, green: 36 / 255, blue: 36 / 255, alpha: 1)
    static let black = UIColor(red: 26 / 255, green: 26 / 255, blue: 26 / 255, alpha: 1)
    static let gray = UIColor(red: 186 / 255, green: 186 / 255, blue: 186 / 255, alpha: 1)
}
