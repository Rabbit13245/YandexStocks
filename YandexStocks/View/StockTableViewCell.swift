//
//  StockTableViewCell.swift
//  YandexStocks
//
//  Created by Admin on 3/23/21.
//

import UIKit

class StockTableViewCell: UITableViewCell {

    public static let identifier = "StockCellId"

    public var favouriteButtonPressed: ((StockTableViewCell) -> Void)?
    
    public var odd: Bool = false {
        didSet {
            if odd {
                bgView.backgroundColor = UIColor(named: "grayColor")
            } else {
                bgView.backgroundColor = UIColor.systemBackground
            }
        }
    }
    
    public var isFavourite: Bool = false {
        didSet {
            if isFavourite {
                favoriteButton.setImage(UIImage(named: "star_selected"), for: .normal)
            } else {
                favoriteButton.setImage(UIImage(named: "star_unselected"), for: .normal)
            }
        }
    }
    
    private(set) var model: Stock?
    
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
    
    // MARK: - Actions
    @IBAction func favouriteButtonPressed(_ sender: UIButton) {
        favouriteButtonPressed?(self)
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
        currentPrice.text = "$" + String(format: "%.2f", model.price)
        delta.text = model.change
        delta.textColor = model.isGrowth ? Color.accentGreen : Color.accentRed
        
        self.model = model
    }
}
