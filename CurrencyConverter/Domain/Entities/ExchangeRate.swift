//
//  ExchangeRate.swift
//  CurrencyConverter
//
//  Created by 서동환 on 4/15/25.
//

import Foundation

// TODO: ExchangeRate로 이름 변경
struct ExchangeRate: Codable {
    let result: String
    let baseCode: String
    let rates: [String: Double]

    enum CodingKeys: String, CodingKey {
        case result
        case baseCode = "base_code"
        case rates
    }
}
