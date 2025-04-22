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

final class MainViewModel: ViewModelProtocol {
    
    // MARK: - Properties
    
    private let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "MainViewModel")
    
    private let dataService = DataService()
    private let currencyMap = currencyMapping
    
    private let disposeBag = DisposeBag()
    
    /// 모든 환율 데이터
    private var allCurrencies = [String: Currency]()
    /// 필터링된 환율 데이터
    private var filteredCurrencies = [String: Currency]()
    
    // MARK: - Action ➡️ Input
    
    struct Action {
        /// 바인딩 이후 알림
        let didBinding: Observable<Void>
        /// 검색중인 통화 코드 or 국가명
        let searchText: Observable<String>
        /// 즐겨찾기 상태를 변경한 환율 데이터
        let favoriteCurrency: Observable<Currency>
    }
    var action: ((Action) -> Void)?
    
    // MARK: - Output ➡️ State
    
    struct State {
        /// 데이터를 불러오는 중 에러 발생 시 true, 이외 false
        var needToShowAlert: ((Bool) -> Void)?
        /// 필터링 & 정렬된 환율 데이터
        var sortedCurrencies: (([Currency]) -> Void)?
        /// "검색 결과 없음" 표시 용도
        var isHiddenEmptyLabel: ((Bool) -> Void)?
    }
    var state: State
    
    // MARK: - Initializer
    
    init() {
        state = State()
        
        action = { [weak self] action in
            guard let self else { return }
            
            // 즐겨찾기 상태 데이터에 반영
            action.favoriteCurrency
                .subscribe(with: self, onNext: { owner, currency in
                    var updatedCurrency = currency
                    updatedCurrency.isFavorite.toggle()
                    CoreDataStorage.shared.updateData(currency: currency)
                    let logMsg = "(currency: \(updatedCurrency.code), isFavorite: \(updatedCurrency.isFavorite))"
                    os_log("updatedCurrency: %@", log: owner.log, type: .debug, logMsg)
                    
                    owner.allCurrencies[updatedCurrency.code] = updatedCurrency
                    owner.filteredCurrencies[updatedCurrency.code] = updatedCurrency
                    owner.acceptSortedCurrencies()
                }).disposed(by: disposeBag)
            
            // 검색어 변경될 때마다 데이터 필터링 및 정렬
            action.searchText
                .subscribe(with: self) { owner, searchText in
                    /*
                     UX 고민
                     - 국가명을 검색할 때는 글자가 포함되기만 해도 결과에 포함되도록 구현
                     - ex) "레일리아" 검색 ➡️ "오스트레일리아" 결과 포함
                     */
                    owner.filteredCurrencies = owner.allCurrencies.filter {
                        $0.value.code.hasPrefix(searchText.uppercased()) ||
                        $0.value.country.lowercased().contains(searchText.lowercased())
                    }
                    os_log("filteredCurrencies.count: %d", log: owner.log, type: .debug, owner.filteredCurrencies.values.count)
                    owner.acceptSortedCurrencies()
                    
                    // 검색 결과가 없을 경우 "검색 결과 없음" 표시
                    let isHidden = searchText.isEmpty == true || owner.filteredCurrencies.isEmpty == false
                    owner.state.isHiddenEmptyLabel?(isHidden)
                }.disposed(by: disposeBag)
            
            // 바인딩 완료 후 데이터 로딩
            action.didBinding
                .subscribe(with: self) { owner, _ in
                    owner.loadCurrencies()
                }.disposed(by: disposeBag)
        }
    }
}

// MARK: - Private Methods

private extension MainViewModel {
    func loadCurrencies() {
        dataService.loadData { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let exchangeRate):
                let remoteExchangeRate = exchangeRate
                
                // Core Data에 데이터 존재 ➡️ 기존 값 유지 or 업데이트
                if let localExchangeRate = CoreDataStorage.shared.fetchData() {
                    os_log("CoreDataStorage) %@", log: log, type: .debug, "\(localExchangeRate)")
                    if localExchangeRate.lastUpdatedUnix != remoteExchangeRate.lastUpdatedUnix {
                        os_log("CoreDataStorage) outdated", log: log, type: .debug)
                        remoteExchangeRate.currencies.forEach { currency in
                            CoreDataStorage.shared.updateData(currency: currency)
                        }
                        os_log("CoreDataStorage) update completed", log: log, type: .debug)
                    }
                    os_log("CoreDataStorage) up-to-date", log: log, type: .debug)
                
                } else {
                    // Core Data가 비어있음 ➡️ 저장
                    CoreDataStorage.shared.saveData(exchangeRate: remoteExchangeRate)
                    os_log("CoreDataStorage) saved", log: log, type: .debug)
                }
                
                allCurrencies = Dictionary(uniqueKeysWithValues: exchangeRate.currencies.map { ($0.code, $0) })
                filteredCurrencies = allCurrencies
                state.needToShowAlert?(false)
                
            case .failure(_):
                allCurrencies = [:]
                filteredCurrencies = allCurrencies
                state.needToShowAlert?(true)
            }
            acceptSortedCurrencies()
        }
    }
    
    func acceptSortedCurrencies() {
        let sortedCurrencies = filteredCurrencies.values.sorted {
            if $0.isFavorite == $1.isFavorite {
                return $0.code < $1.code
            }
            return $0.isFavorite == true
        }
        state.sortedCurrencies?(sortedCurrencies)
    }
}
