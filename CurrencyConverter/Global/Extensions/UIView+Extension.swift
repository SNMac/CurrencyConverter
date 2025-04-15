//
//  UIView+Extension.swift
//  CurrencyConverter
//
//  Created by 서동환 on 3/28/25.
//

import UIKit

extension UIView {
    /// 한번에 여러 개의 subView를 추가할 수 있게 하는 Extension
    func addSubviews(_ views: UIView...) {
        views.forEach {
            self.addSubview($0)
        }
    }
}
