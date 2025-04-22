//
//  Currency.swift
//  CurrencyConverter
//
//  Created by 서동환 on 4/17/25.
//

import Foundation

struct Currency: Hashable {
    let code: String
    let country: String
    var difference: Double
    var rate: Double
    var isFavorite: Bool
    
    init(
        code: String = "",
        country: String = "",
        difference: Double = 0.0,
        rate: Double = 0.0,
        isFavorite: Bool = false
    ) {
        self.code = code
        self.country = country
        self.difference = difference
        self.rate = rate
        self.isFavorite = isFavorite
    }
}
