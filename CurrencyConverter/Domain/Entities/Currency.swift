//
//  Currency.swift
//  CurrencyConverter
//
//  Created by 서동환 on 4/17/25.
//

import Foundation

struct Currency {
    let code: String
    let country: String
    var rate: Double
    var difference: Double
    var isFavorite: Bool
    
    init(
        code: String = "",
        country: String = "",
        rate: Double = 0.0,
        difference: Double = 0.0,
        isFavorite: Bool = false
    ) {
        self.code = code
        self.country = country
        self.rate = rate
        self.difference = difference
        self.isFavorite = isFavorite
    }
}
