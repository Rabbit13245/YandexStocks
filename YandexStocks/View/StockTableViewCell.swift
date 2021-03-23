//
//  StockTableViewCell.swift
//  YandexStocks
//
//  Created by Admin on 3/23/21.
//

import UIKit

class StockTableViewCell: UITableViewCell {

    public static let identifier = "StockCellId"
    public var odd: Bool = false {
        didSet {
            if odd {
                bgView.backgroundColor = Color.gray
            } else {
                bgView.backgroundColor = UIColor.systemBackground
            }
        }
    }
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var ticker: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var currentPrice: UILabel!
    @IBOutlet weak var delta: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    // MARK: - Private
    private func setupView() {
        bgView.layer.cornerRadius = 16
        logo.layer.cornerRadius = 12
    }
}

extension StockTableViewCell: IConfigurableView {
    typealias IConfigurationModel = Stock
    
    func configure(with model: IConfigurationModel) {
        name.text = model.name
        ticker.text = model.ticker
    }
}
