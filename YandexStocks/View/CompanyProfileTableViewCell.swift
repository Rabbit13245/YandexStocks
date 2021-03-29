//
//  CompanyProfileTableViewCell.swift
//  YandexStocks
//
//  Created by Дмитрий Зайцев on 28.03.2021.
//

import UIKit

class CompanyProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var fieldName: UILabel!
    @IBOutlet weak var fieldValue: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    // MARK: - Private
    private func setupView() {
        fieldName.font = Font.H4
        fieldValue.font = Font.H3
    }
}

extension CompanyProfileTableViewCell: IConfigurableView {
    typealias IConfigurationModel = (String, String)
    
    func configure(with model: (String, String)) {
        fieldName.text = model.0
        fieldValue.text = model.1
        
        if model.0 == "Web" || model.0 == "Phone" {
            fieldValue.textColor = UIColor.link
        }
    }
}
