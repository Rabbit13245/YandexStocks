//
//  UIView.swift
//  YandexStocks
//
//  Created by Дмитрий Зайцев on 29.03.2021.
//

import UIKit

extension UIView {
    func animateHidding(hidding: Bool) {
        UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
            if hidding {
                self.alpha = 0
            } else {
                self.alpha = 1
            }
        }, completion: { _ in
            self.isHidden = hidding
        })
    }
}
