//
//  CurrencyTableView.swift
//  CurrencyConverter
//
//  Created by 서동환 on 4/15/25.
//

import UIKit

final class CurrencyTableView: UITableView {
    
    // MARK: - Initializer
    
    override init(frame: CGRect = .zero, style: UITableView.Style = .plain) {
        super.init(frame: frame, style: style)
        self.backgroundColor = .systemBackground
        self.separatorInset.left = 16
        self.separatorInset.right = 16
        self.register(CurrencyCell.self, forCellReuseIdentifier: CurrencyCell.identifier)
        self.rowHeight = 60
        self.keyboardDismissMode = .onDrag
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
