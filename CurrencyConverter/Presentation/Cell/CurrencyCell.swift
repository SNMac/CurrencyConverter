//
//  CurrencyCell.swift
//  CurrencyConverter
//
//  Created by 서동환 on 4/15/25.
//

import UIKit
import RxSwift
import SnapKit
import Then

final class CurrencyCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let identifier = "CurrencyCell"
    var disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    private let currencyLabel = UILabel().then {
        $0.text = "XCG"
        $0.font = .systemFont(ofSize: 16, weight: .medium)
    }
    
    private let countryLabel = UILabel().then {
        $0.text = "가상통화 (Crypto Generic)"
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = .gray
    }
    
    private let labelStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 4
    }
    
    private let rateLabel = UILabel().then {
        $0.text = "1.7900"
        $0.font = .systemFont(ofSize: 16)
        $0.textAlignment = .right
    }
    
    let favoriteButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "star")?.withRenderingMode(.alwaysOriginal)
        config.baseBackgroundColor = .clear
        $0.configuration = config
        $0.contentMode = .scaleAspectFit
        
        $0.configurationUpdateHandler = { button in
            var config = button.configuration
            
            switch button.state {
            case .selected:
                config?.image = UIImage(systemName: "star.fill")?.withRenderingMode(.alwaysOriginal)
            default:
                config?.image = UIImage(systemName: "star")?.withRenderingMode(.alwaysOriginal)
            }
            
            button.configuration = config
        }
    }
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    // MARK: - Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Methods

extension CurrencyCell {
    func configure(currencyModel: CurrencyModel) {
        currencyLabel.text = currencyModel.currency
        countryLabel.text = currencyModel.country
        rateLabel.text = String(format: "%.4f", currencyModel.rate)
        favoriteButton.isSelected = currencyModel.isFavorite
    }
}

// MARK: - UI Methods

private extension CurrencyCell {
    func setupUI() {
        setViewHierarchy()
        setConstraints()
    }
    
    func setViewHierarchy() {
        self.contentView.addSubviews(labelStackView, rateLabel, favoriteButton)
        
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
            $0.centerY.equalToSuperview()
            $0.leading.greaterThanOrEqualTo(labelStackView.snp.trailing).offset(16)
            $0.width.equalTo(120)
        }
        
        favoriteButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(rateLabel.snp.trailing).offset(8)
            $0.width.height.equalTo(44)
        }
    }
}
