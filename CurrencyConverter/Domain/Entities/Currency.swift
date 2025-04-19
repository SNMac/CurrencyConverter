//
//  Currency.swift
//  CurrencyConverter
//
//  Created by 서동환 on 4/15/25.
//

import Foundation

struct Currency: Codable {
    let result: String
    let baseCode: String
    let rates: [String: Double]

    enum CodingKeys: String, CodingKey {
        case result
        case baseCode = "base_code"
        case rates
    }
}
