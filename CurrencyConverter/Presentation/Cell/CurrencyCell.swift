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
    
    private let currencyCodeLabel = UILabel().then {
        $0.text = "KRW"
        $0.font = .systemFont(ofSize: 17, weight: .medium)
    }
    
    private let exchangeRateLabel = UILabel().then {
        $0.text = "1000"
        $0.font = .systemFont(ofSize: 17)
    }
    
    // MARK: - Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UI Methods

private extension CurrencyCell {
    func setupUI() {
        setViewHierarchy()
        setConstraints()
    }
    
    func setViewHierarchy() {
        self.addSubviews(currencyCodeLabel, exchangeRateLabel)
    }
    
    func setConstraints() {
        currencyCodeLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(15)
            $0.centerY.equalToSuperview()
        }
        
        exchangeRateLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(15)
            $0.centerY.equalToSuperview()
        }
    }
}
