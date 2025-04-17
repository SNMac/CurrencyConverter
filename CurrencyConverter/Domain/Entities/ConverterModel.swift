//
//  ConverterModel.swift
//  CurrencyConverter
//
//  Created by 서동환 on 4/17/25.
//

import Foundation

struct ConverterModel {
    let currency: String
    let country: String
    
    init(currency: String = "", country: String = "") {
        self.currency = currency
        self.country = country
    }
}
