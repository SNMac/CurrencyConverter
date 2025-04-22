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
    var difference: Double
    var rate: Double
    var isFavorite: Bool
}
