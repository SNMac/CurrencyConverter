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

final class MainViewModel {
    
    // MARK: - Properties
    
    private let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "MainViewModel")
    
    private let dataService = DataService()
    private let currencyMap = currencyMapping
    
    private let disposeBag = DisposeBag()
    
    /// 모든 환율 데이터
    private var allCurrencies = [CurrencyModel]()
    
    // MARK: - User Action ➡️ Input
    
    struct Input {
        /// 검색중인 통화 코드 or 국가명
        let searchText: Observable<String>
    }
    
    // MARK: - Output ➡️ Data
    
    struct Output {
        /// 데이터를 불러오는 중 에러 발생시 true, 이외 false
        let needToShowAlert: BehaviorRelay<Bool>
        /// 현재 보여지고 있는 환율 데이터
        let showingCurrencies: BehaviorRelay<[CurrencyModel]>
        /// "검색 결과 없음" 표시 용도
        let isHiddenEmptyLabel: PublishRelay<Bool>
    }
    
    // TODO: Input, Output 구조체만 남기기
    private let needToShowAlert = BehaviorRelay<Bool>(value: false)
    private let showingCurrencies = BehaviorRelay<[CurrencyModel]>(value: [])
    
    // MARK: - Initializer
    
    init() {
        loadData()
    }
}

// MARK: - Methods

extension MainViewModel {
    func transform(input: Input) -> Output {
        let isHiddenEmptyLabel = PublishRelay<Bool>()
        
        // 검색에 따라 데이터 필터링
        input.searchText
            .subscribe(with: self) { owner, searchText in
                /*
                 UX 고민
                 - 국가명을 검색할 때는 글자가 포함되기만 해도 결과에 포함되도록 구현
                 - ex) "레일리아" 검색 ➡️ "오스트레일리아" 결과 포함
                 */
                let filteredCurrencies = owner.allCurrencies.filter {
                    $0.currency.hasPrefix(searchText.uppercased()) ||
                    $0.country.lowercased().contains(searchText.lowercased())
                }
                owner.showingCurrencies.accept(filteredCurrencies)
                os_log("showingRates.count: %d", log: owner.log, type: .debug, owner.showingCurrencies.value.count)
            }.disposed(by: disposeBag)
        
        // 검색 결과가 없을 경우 "검색 결과 없음" 표시
        Observable.combineLatest(input.searchText, showingCurrencies)
            .map { searchText, showingRates in
                searchText.isEmpty == true || showingRates.isEmpty == false
            }
            .bind(to: isHiddenEmptyLabel)
            .disposed(by: disposeBag)
        
        return Output(needToShowAlert: needToShowAlert,
                      showingCurrencies: showingCurrencies,
                      isHiddenEmptyLabel: isHiddenEmptyLabel)
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
                needToShowAlert.accept(false)
                
            case .failure(_):
                allCurrencies = []
                showingCurrencies.accept([])
                needToShowAlert.accept(true)
            }
        }
    }
}
