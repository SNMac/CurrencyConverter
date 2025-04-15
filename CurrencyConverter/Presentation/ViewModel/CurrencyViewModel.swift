//
//  CurrencyViewModel.swift
//  CurrencyConverter
//
//  Created by 서동환 on 4/15/25.
//

import Foundation
import RxSwift

final class CurrencyViewModel {
    
    // MARK: - Properties
    
    private let dataService = DataService()
    private var rates: [String: Double]?
    
    // MARK: - Data ➡️ Output
    
    var cellCount = BehaviorSubject<Int>(value: 0)
    var loadCurrencyError = PublishSubject<Bool>()
    
    /// 통화 코드
    var currencyCodes = [BehaviorSubject<String>]()
    /// 환율
    var exchangeRates = [BehaviorSubject<Double>]()
    
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
                rates = currency.rates
                if let rates = rates {
                    cellCount.onNext(rates.count)
                    for rate in rates.sorted(by: { $0.key < $1.key }) {
                        currencyCodes.append(BehaviorSubject(value: rate.key))
                        exchangeRates.append(BehaviorSubject(value: rate.value))
                    }
                }
                
            case .failure(_):
                rates = nil
                cellCount.onNext(0)
                loadCurrencyError.onNext(false)
            }
        }
    }
}
