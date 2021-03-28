//
//  StockTableViewCell.swift
//  YandexStocks
//
//  Created by Admin on 3/23/21.
//

import UIKit
import Kingfisher

class StockTableViewCell: UITableViewCell {
    
    private(set) var stockTicker: String? {
        didSet {
            ticker.text = stockTicker
        }
    }

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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        stockTicker = nil
        favouriteButtonPressed = nil
        isFavourite = false
        logo.image = UIImage(systemName: "banknote")
    }
    
    // MARK: - Actions
    @IBAction func favouriteButtonPressed(_ sender: UIButton) {
        favouriteButtonPressed?(self)
        
        sender.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: 0.2,
          delay: 0,
          usingSpringWithDamping: 0.2,
          initialSpringVelocity: 6.0,
          options: .allowUserInteraction,
          animations: {
            sender.transform = .identity
          },
          completion: nil)
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
        stockTicker = model.ticker
        
        name.text = model.name
        currentPrice.text = "$" + String(format: "%.2f", model.price)
        delta.text = model.change
        delta.textColor = model.isGrowth ? Color.accentGreen : Color.accentRed
        isFavourite = model.isFavourite
        
        if let logoUrlString = model.logoUrl,
           let logoUrl = URL(string: logoUrlString) {
            logo.kf.setImage(with: logoUrl)
        }
    }
}
