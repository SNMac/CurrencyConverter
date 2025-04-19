//
//  CurrencyModel.swift
//  CurrencyConverter
//
//  Created by 서동환 on 4/17/25.
//

import Foundation

struct CurrencyModel {
    let currency: String
    let country: String
    var rate: Double
    var isFavorite: Bool
    
    init(currency: String = "", country: String = "", rate: Double = 0.0, isFavorite: Bool = false) {
        self.currency = currency
        self.country = country
        self.rate = rate
        self.isFavorite = isFavorite
    }
}
