//
//  ExchangeRateEntity+Mapping.swift
//  CurrencyConverter
//
//  Created by 서동환 on 4/22/25.
//

import Foundation

extension ExchangeRateEntity {
    func toDomain() -> ExchangeRate {
        let currencyEntites = currencies?.allObjects as? [CurrencyEntity] ?? []
        let currencies = currencyEntites.map { $0.toDomain() }
        return .init(lastUpdatedUnix: lastUpdatedUnix,
                     baseCode: baseCode ?? "",
                     currencies: currencies)
    }
}

extension CurrencyEntity {
    func toDomain() -> Currency {
        return .init(code: code ?? "",
                     country: country ?? "",
                     rate: rate,
                     difference: difference,
                     isFavorite: isFavorite)
    }
}
