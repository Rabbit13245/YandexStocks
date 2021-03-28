//
//  StockHeaderView.swift
//  YandexStocks
//
//  Created by Admin on 3/25/21.
//

import UIKit

class StockHeaderView: UIView {
    // MARK: - Public
    var valueChangedCallback: ((Int) -> Void)?
    var segControlEnabled = true {
        didSet {
            segmentedControl.isEnabled = segControlEnabled
        }
    }
    // MARK: - Private
    private var segments: [String]
    
    // MARK: - UI
    private lazy var segmentedControl: UISegmentedControl = {
        let segControl = UISegmentedControl(items: segments)
        segControl.translatesAutoresizingMaskIntoConstraints = false
        segControl.selectedSegmentIndex = 0
        segControl.tintColor = UIColor(named: "grayColor")
        segControl.backgroundColor = UIColor.systemBackground
        segControl.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
        return segControl
    }()
    
    // MARK: - Initializers
    init(segments: [String]) {
        self.segments = segments
        super.init(frame: .zero)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    private func setupView() {
        addSubview(segmentedControl)
        backgroundColor = UIColor.systemBackground
        NSLayoutConstraint.activate([
            segmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor),
            segmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor),
            segmentedControl.topAnchor.constraint(equalTo: topAnchor),
            segmentedControl.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    // MARK: - Actions
    @objc private func valueChanged(sender: UISegmentedControl) {
        valueChangedCallback?(sender.selectedSegmentIndex)
    }
}
