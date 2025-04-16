//
//  CurrencyTableView.swift
//  CurrencyConverter
//
//  Created by 서동환 on 4/15/25.
//

import UIKit

final class CurrencyTableView: UITableView {
    
    // MARK: - Initializer
    
    override init(frame: CGRect, style: UITableView.Style = .plain) {
        super.init(frame: frame, style: style)
        self.register(CurrencyCell.self, forCellReuseIdentifier: CurrencyCell.identifier)
        // height = 60
        self.rowHeight = 60
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
