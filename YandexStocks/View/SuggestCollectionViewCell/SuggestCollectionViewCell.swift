//
//  SuggestCollectionViewCell.swift
//  YandexStocks
//
//  Created by Admin on 4/2/21.
//

import UIKit

class SuggestCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var suggestLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    private func setupView() {
        backgroundColor = UIColor(named: "grayColor")
        layer.cornerRadius = 20
    }
}
