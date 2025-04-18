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
    
    init(currency: String = "", country: String = "", rate: Double = 0.0) {
        self.currency = currency
        self.country = country
        self.rate = rate
    }
}
