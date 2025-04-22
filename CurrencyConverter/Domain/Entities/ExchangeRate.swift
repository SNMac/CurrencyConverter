//
//  ExchangeRate.swift
//  CurrencyConverter
//
//  Created by 서동환 on 4/22/25.
//

import Foundation

struct ExchangeRate: Hashable {
    let lastUpdatedUnix: Double
    let baseCode: String
    var currencies: [Currency]
}
