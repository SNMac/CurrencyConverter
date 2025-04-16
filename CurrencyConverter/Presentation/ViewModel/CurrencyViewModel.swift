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
    
    /// 모든 환율 데이터 [통화코드: (국가명, 환율)]
    var allRates = [String: (country: String, rate: Double)]()
    /// 현재 보여지고 있는 환율 데이터
    var showingRates = BehaviorRelay<[String: (country: String, rate: Double)]>(value: [:])
    /// 총 셀 개수
    var cellCount = BehaviorRelay<Int>(value: 0)
    /// 데이터를 불러오는 중 에러 발생시 true, 이외 false
    var isErrorOccured = BehaviorRelay<Bool>(value: false)
    
    init() {
        loadCurrency()
    }
}

// MARK: - Methods

extension CurrencyViewModel {
    func searchCurrency(of text: String) {
        /*
         UX 고민
         - 국가명을 검색할 때는 글자가 포함되기만 해도 결과에 포함되도록 구현
         - ex) "레일리아" 검색 ➡️ "오스트레일리아" 결과 포함
         */
        let filteredRates = allRates.filter {
            $0.key.hasPrefix(text.uppercased()) ||
            $0.value.country.lowercased().contains(text.lowercased())
        }
        print(filteredRates)
        showingRates.accept(filteredRates)
    }
}

// MARK: - Private Methods

private extension CurrencyViewModel {
    func loadCurrency() {
        dataService.loadCurrency { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let currency):
                var preprocessData: [String: (country: String, rate: Double)] = [:]
                for rate in currency.rates {
                    let country = currencyMap[rate.key] ?? ""
                    preprocessData[rate.key] = (country, rate.value)
                }
                allRates = preprocessData
                showingRates.accept(preprocessData)
                cellCount.accept(showingRates.value.count)
                
            case .failure(_):
                showingRates.accept([:])
                cellCount.accept(0)
                isErrorOccured.accept(true)
            }
        }
    }
}
