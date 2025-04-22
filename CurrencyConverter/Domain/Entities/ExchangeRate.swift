//
//  ExchangeRate.swift
//  CurrencyConverter
//
//  Created by 서동환 on 4/22/25.
//

import Foundation

struct ExchangeRate {
    let lastUpdatedUnix: Double
    let baseCode: String
    var currencies: [Currency]
}
