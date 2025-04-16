//
//  CurrencyCell.swift
//  CurrencyConverter
//
//  Created by 서동환 on 4/15/25.
//

import UIKit
import SnapKit

final class CurrencyCell: UITableViewCell {
    
    static let identifier = "CurrencyCell"
    
    // MARK: - UI Components
    
    private let labelStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 4
    }
    
    private let currencyLabel = UILabel().then {
        $0.text = "XCG"
        $0.font = .systemFont(ofSize: 16, weight: .medium)
    }
    
    private let countryLabel = UILabel().then {
        $0.text = "가상통화 (Crypto Generic)"
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = .gray
    }
    
    private let rateLabel = UILabel().then {
        $0.text = "1.7900"
        $0.font = .systemFont(ofSize: 16)
        $0.textAlignment = .right
    }
    
    // MARK: - Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    func configure(currency: String, country: String, rate: Double) {
        currencyLabel.text = currency
        countryLabel.text = country
        rateLabel.text = String(format: "%.4f", rate)
    }
}

// MARK: - UI Methods

private extension CurrencyCell {
    func setupUI() {
        setViewHierarchy()
        setConstraints()
    }
    
    func setViewHierarchy() {
        self.addSubviews(labelStackView, rateLabel)
        
        labelStackView.addArrangedSubviews(
            currencyLabel,
            countryLabel
        )
    }
    
    func setConstraints() {
        // leading = superView + 16
        // centerY = superView
        labelStackView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
        
        // trailing = superView - 16
        // centerY = superView
        // leading ≥ labelStackView.trailing + 16
        // width = 120
        rateLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.leading.greaterThanOrEqualTo(labelStackView.snp.trailing).offset(16)
            $0.width.equalTo(120)
        }
    }
}
