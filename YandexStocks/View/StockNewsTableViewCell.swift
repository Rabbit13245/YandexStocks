//
//  StockNewsTableViewCell.swift
//  YandexStocks
//
//  Created by Дмитрий Зайцев on 28.03.2021.
//

import UIKit
import Kingfisher

class StockNewsTableViewCell: UITableViewCell {

    @IBOutlet weak var newsImage: UIImageView!
    @IBOutlet weak var headline: UILabel!
    @IBOutlet weak var dateTime: UILabel!
    @IBOutlet weak var source: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    // MARK: - Private
    private func setupView() {
        headline.font = Font.H2
        headline.textColor = UIColor.label
        dateTime.font = Font.Body
        dateTime.textColor = UIColor.secondaryLabel
        source.font = Font.Body
        source.textColor = UIColor.secondaryLabel
        newsImage.contentMode = .scaleAspectFill
    }
}

extension StockNewsTableViewCell: IConfigurableView {
    typealias IConfigurationModel = News
    
    func configure(with model: News) {
        headline.text = model.headline
        source.text = model.source
        dateTime.text = Double(model.datetime).getDateFromUtc()
        if let imageUrl = URL(string: model.imageUrlString) {
            newsImage.kf.setImage(with: imageUrl)
        }
    }
}
