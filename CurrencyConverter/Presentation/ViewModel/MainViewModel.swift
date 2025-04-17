//
//  MainViewModel.swift
//  CurrencyConverter
//
//  Created by 서동환 on 4/15/25.
//

import Foundation
import OSLog
import RxSwift
import RxRelay
import RxCocoa

final class MainViewModel {
    
    // MARK: - Properties
    
    private let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "CurrencyViewModel")
    
    private let dataService = DataService()
    private let currencyMap = currencyMapping
    
    private let disposeBag = DisposeBag()
    
    /// 모든 환율 데이터
    private var allCurrencies = [CurrencyModel]()
    
    // MARK: - User Action ➡️ Input
    
    struct Input {
        /// 검색중인 통화 코드 or 국가명
        let searchText: ControlProperty<String>
    }

    // MARK: - Data ➡️ Output
    
    struct Output {
        /// 데이터를 불러오는 중 에러 발생시 true, 이외 false
        let isErrorOccurred: BehaviorRelay<Bool>
        /// 현재 보여지고 있는 환율 데이터
        let showingCurrencies: BehaviorRelay<[CurrencyModel]>
    }
    
    private let isErrorOccurred = BehaviorRelay<Bool>(value: false)
    private let showingCurrencies = BehaviorRelay<[CurrencyModel]>(value: [])
    
    // MARK: - Initializer
    
    init() {
        loadData()
    }
}

// MARK: - Methods

extension MainViewModel {
    func transform(input: Input) -> Output {
        input.searchText
            .asDriver(onErrorJustReturn: "")
            .drive(with: self, onNext: { owner, searchText in
                /*
                 UX 고민
                 - 국가명을 검색할 때는 글자가 포함되기만 해도 결과에 포함되도록 구현
                 - ex) "레일리아" 검색 ➡️ "오스트레일리아" 결과 포함
                 */
                let filteredRates = self.allCurrencies.filter {
                    $0.currency.hasPrefix(searchText.uppercased()) ||
                    $0.country.lowercased().contains(searchText.lowercased())
                }
                owner.showingCurrencies.accept(filteredRates)
                os_log("showingRates.count: %d", log: owner.log, type: .debug, owner.showingCurrencies.value.count)
            }).disposed(by: disposeBag)
        
        return Output(isErrorOccurred: isErrorOccurred, showingCurrencies: showingCurrencies)
    }
}

// MARK: - Private Methods

private extension MainViewModel {
    func loadData() {
        dataService.loadCurrency { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let currency):
                allCurrencies = currency.rates.map {
                    let country = self.currencyMap[$0.key] ?? ""
                    return CurrencyModel(currency: $0.key, country: country, rate: $0.value)
                }.sorted(by: { $0.currency < $1.currency })
                showingCurrencies.accept(allCurrencies)
                isErrorOccurred.accept(false)
                
            case .failure(_):
                allCurrencies = []
                showingCurrencies.accept([])
                isErrorOccurred.accept(true)
            }
        }
    }
}
