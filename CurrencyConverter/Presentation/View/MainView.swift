//
//  MainView.swift
//  CurrencyConverter
//
//  Created by 서동환 on 4/16/25.
//

import UIKit
import SnapKit
import Then

final class MainView: UIView {
    
    // MARK: - UI Components
    
    let currencySearchBar = CurrencySearchBar()
    
    let currencyTableView = CurrencyTableView()
    
    let emptyStateLabel = UILabel().then {
        $0.text = "검색 결과 없음"
        $0.font = .systemFont(ofSize: 16)
        $0.textColor = .gray
        $0.textAlignment = .center
        $0.isHidden = true
    }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UI Methods

private extension MainView {
    func setupUI() {
        setViewHierarchy()
        setConstraints()
    }
    
    func setViewHierarchy() {
        self.addSubviews(
            currencySearchBar,
            currencyTableView,
            emptyStateLabel
        )
    }
    
    func setConstraints() {
        // top = safeAreaLayoutGuide
        // leading, trailing = superView
        currencySearchBar.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
        }
        
        emptyStateLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(self.safeAreaLayoutGuide).offset(currencySearchBar.frame.height)
            $0.width.equalTo(100)
        }
        
        // top = searchBar.bottom
        // leading, trailing, bottom = safeAreaLayoutGuide
        currencyTableView.snp.makeConstraints {
            $0.top.equalTo(currencySearchBar.snp.bottom)
            $0.leading.trailing.bottom.equalTo(self.safeAreaLayoutGuide)
        }
    }
    
}
