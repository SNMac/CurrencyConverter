//
//  ConverterView.swift
//  CurrencyConverter
//
//  Created by 서동환 on 4/17/25.
//

import UIKit
import SnapKit
import Then

final class ConverterView: UIView {
    
    // MARK: - UI Components
    
    let codeLabel = UILabel().then {
        $0.text = "XCG"
        $0.font = .systemFont(ofSize: 24, weight: .bold)
    }
    
    let countryLabel = UILabel().then {
        $0.text = "가상통화 (Crypto Generic)"
        $0.font = .systemFont(ofSize: 16)
        $0.textColor = .systemGray
    }
    
    private let labelStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 4
        $0.alignment = .center
    }
    
    let amountTextField = UITextField().then {
        $0.borderStyle = .roundedRect
        $0.keyboardType = .decimalPad
        $0.textAlignment = .center
        $0.placeholder = "달러(USD)를 입력하세요"
    }
    
    let convertButton = UIButton().then {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .systemBlue
        var titleContainer = AttributeContainer()
        titleContainer.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleContainer.foregroundColor = .white
        config.attributedTitle = AttributedString("환율 계산", attributes: titleContainer)
        $0.configuration = config
        $0.layer.cornerRadius = 8
    }
    
    let resultLabel = UILabel().then {
        $0.text = "계산 결과가 여기에 표시됩니다"
        $0.font = .systemFont(ofSize: 20, weight: .medium)
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UI Methods

private extension ConverterView {
    func setupUI() {
        setViewHierarchy()
        setConstraints()
    }
    
    func setViewHierarchy() {
        self.addSubviews(
            labelStackView,
            amountTextField,
            convertButton,
            resultLabel
        )
        
        labelStackView.addArrangedSubviews(
            codeLabel,
            countryLabel
        )
    }
    
    func setConstraints() {
        // top = safeArea + 32
        // centerX = superView
        labelStackView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide).inset(32)
            $0.centerX.equalToSuperview()
        }
        
        // top = labelStackView.bottom + 32
        // leading, trailing = superView ± 24
        // height = 44
        amountTextField.snp.makeConstraints {
            $0.top.equalTo(labelStackView.snp.bottom).offset(32)
            $0.leading.trailing.equalTo(self.safeAreaLayoutGuide).inset(24)
            $0.height.equalTo(44)
        }
        
        // top = amountTextField.bottom + 24
        // leading, trailing = superView ± 24
        // height = 44
        convertButton.snp.makeConstraints {
            $0.top.equalTo(amountTextField.snp.bottom).offset(24)
            $0.leading.trailing.equalTo(self.safeAreaLayoutGuide).inset(24)
            $0.height.equalTo(44)
        }
        
        // top = convertButton.bottom + 32
        // leading, trailing = superView ± 24
        resultLabel.snp.makeConstraints {
            $0.top.equalTo(convertButton.snp.bottom).offset(32)
            $0.leading.trailing.equalTo(self.safeAreaLayoutGuide).inset(24)
        }
    }
    
}
