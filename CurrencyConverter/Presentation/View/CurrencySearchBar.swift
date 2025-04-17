//
//  CurrencySearchBar.swift
//  CurrencyConverter
//
//  Created by 서동환 on 4/16/25.
//

import UIKit

final class CurrencySearchBar: UISearchBar {
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.searchBarStyle = .minimal
        self.placeholder = "통화 검색"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
