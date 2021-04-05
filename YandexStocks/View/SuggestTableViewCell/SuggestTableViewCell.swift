//
//  SuggestTableViewCell.swift
//  YandexStocks
//
//  Created by Admin on 4/2/21.
//

import UIKit

class SuggestTableViewCell: UITableViewCell {
    
    var didSelectPopularRequest: ((String) -> Void)?
    // MARK: - Private
    let popularRequests = ["Apple", "Tesla", "AT&T", "Intel"]
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: String(describing: SuggestCollectionViewCell.self), bundle: nil),
                                forCellWithReuseIdentifier: String(describing: SuggestCollectionViewCell.self))
    }
}

extension SuggestTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return popularRequests.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: SuggestCollectionViewCell.self),
                for: indexPath) as? SuggestCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let model = popularRequests[indexPath.row]
        cell.suggestLabel.text = model
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let request = popularRequests[indexPath.row]
        didSelectPopularRequest?(request)
    }
}

extension SuggestTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 100, height: 40)
    }
}

extension SuggestTableViewCell: IConfigurableView {
    typealias IConfigurationModel = String
    
    func configure(with model: String) {
        collectionView.layoutSubviews()
    }
}
