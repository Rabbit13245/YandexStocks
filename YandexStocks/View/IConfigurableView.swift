//
//  IConfigurableView.swift
//  YandexStocks
//
//  Created by Admin on 3/23/21.
//

import Foundation

protocol IConfigurableView {
    associatedtype IConfigurationModel
    
    func configure(with model: IConfigurationModel)
}
