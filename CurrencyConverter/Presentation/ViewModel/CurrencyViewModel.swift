//
//  CurrencyViewModel.swift
//  CurrencyConverter
//
//  Created by 서동환 on 4/15/25.
//

import Foundation
import RxRelay

final class CurrencyViewModel {
    
    // MARK: - Properties
    
    private let dataService = DataService()
    private let currencyMap = currencyMapping
    
    // MARK: - Data ➡️ Output
    
    var cellCount = BehaviorRelay<Int>(value: 0)
    var isErrorOccured = BehaviorRelay<Bool>(value: false)
    
    /// [통화코드: 환율]
    var rates = BehaviorRelay<[String: (country: String, rate: Double)]>(value: [:])
    
    init() {
        loadCurrency()
    }
}

private extension CurrencyViewModel {
    func loadCurrency() {
        dataService.loadCurrency { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let currency):
                var preprocessData = [String: (country: String, rate: Double)]()
                for rate in currency.rates {
                    guard let country = currencyMap[rate.key] else { continue }
                    preprocessData[rate.key] = (country, rate.value)
                }
                rates.accept(preprocessData)
                cellCount.accept(rates.value.count)
                
            case .failure(_):
                rates.accept([:])
                cellCount.accept(0)
                isErrorOccured.accept(true)
            }
        }
    }
}
