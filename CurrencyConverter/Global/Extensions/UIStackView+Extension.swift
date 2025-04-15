//
//  UIStackView+Extension.swift
//  CurrencyConverter
//
//  Created by 서동환 on 3/28/25.
//

import UIKit

extension UIStackView {
    /// UIStackView에서 한번에 여러 개의 arrangedSubView를 추가할 수 있게 하는 Extension
    func addArrangedSubviews(_ views: UIView...) {
        views.forEach {
            self.addArrangedSubview($0)
        }
    }
}
