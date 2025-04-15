//
//  CurrencyTableView.swift
//  CurrencyConverter
//
//  Created by 서동환 on 4/15/25.
//

import UIKit

final class CurrencyTableView: UITableView {
    
    // MARK: - Initializer
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        self.register(CurrencyTableViewCell.self, forCellReuseIdentifier: CurrencyTableViewCell.identifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
