//
//  ExchangeRateDTO.swift
//  CurrencyConverter
//
//  Created by 서동환 on 4/15/25.
//

import Foundation

struct ExchangeRateDTO: Decodable {
    enum CodingKeys: String, CodingKey {
        case lastUpdatedUnix = "time_last_update_unix"
        case baseCode = "base_code"
        case currencies = "rates"
    }
    
    let lastUpdatedUnix: Double
    let baseCode: String
    let currencyDTOs: [CurrencyDTO]
    
    struct CurrencyDTO {
        let code: String
        let country: String
        let rate: Double
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.lastUpdatedUnix = try container.decode(Double.self, forKey: .lastUpdatedUnix)
        self.baseCode = try container.decode(String.self, forKey: .baseCode)
        let currencyDict = try container.decode([String: Double].self, forKey: .currencies)
        self.currencyDTOs = currencyDict.map {
            let country = currencyMapping[$0.key] ?? ""
            return CurrencyDTO(code: $0.key,
                               country: country,
                               rate: $0.value)
        }
    }
}

extension ExchangeRateDTO {
    func toDomain() -> ExchangeRate {
        ExchangeRate(lastUpdatedUnix: lastUpdatedUnix,
                     baseCode: baseCode,
                     currencies: currencyDTOs.map { $0.toDomain() })
    }
}

extension ExchangeRateDTO.CurrencyDTO {
    func toDomain() -> Currency {
        Currency(code: code, country: country, rate: rate)
    }
}
