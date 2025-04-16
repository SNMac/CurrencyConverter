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
    
    // MARK: - Data ➡️ Output
    
    var cellCount = BehaviorRelay<Int>(value: 0)
    var loadCurrencyError = PublishRelay<Bool>()
    
    /// [통화코드: 환율]
    var rates = BehaviorRelay<[String: Double]>(value: [:])
    
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
                rates.accept(currency.rates)
                cellCount.accept(rates.value.count)
                
            case .failure(_):
                rates.accept([:])
                cellCount.accept(0)
                loadCurrencyError.accept(true)
            }
        }
    }
}
