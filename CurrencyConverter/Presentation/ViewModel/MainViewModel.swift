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
    private var allCurrencies = [String: CurrencyModel]()
    
    // MARK: - Action ➡️ Input
    
    struct Action {
        /// 바인딩 이후 알림
        let didBinding: Observable<Void>
        /// 검색중인 통화 코드 or 국가명
        let searchText: Observable<String>
        /// 즐겨찾기 상태를 변경한 환율 데이터
        let favoriteCurrency: Observable<CurrencyModel>
    }
    var action: ((Action) -> Void)?
    
    // MARK: - Output ➡️ State
    
    struct State {
        /// 데이터를 불러오는 중 에러 발생시 true, 이외 false
        var needToShowAlert: ((Bool) -> Void)?
        /// 필터링된(=보여지는) 환율 데이터 배열
        var filteredCurrencies: (([CurrencyModel]) -> Void)?
        /// "검색 결과 없음" 표시 용도
        var isHiddenEmptyLabel: ((Bool) -> Void)?
    }
    var state: State
    
    // MARK: - Initializer
    
    init() {
        state = State()
        
        action = { [weak self] action in
            guard let self else { return }
            
            // 검색어 저장(merge 이벤트 생성용)
            let searchTextRelay = BehaviorRelay<String>(value: "")
            action.searchText
                .bind(to: searchTextRelay)
                .disposed(by: disposeBag)
            
            // 즐겨찾기 상태 데이터에 반영
            action.favoriteCurrency
                .subscribe(with: self) { owner, model in
                    var updatedModel = model
                    updatedModel.isFavorite.toggle()
                    let logMsg = "(currency: \(updatedModel.currency), isFavorite: \(updatedModel.isFavorite))"
                    os_log("updatedModel: %@", log: owner.log, type: .debug, logMsg)
                    owner.allCurrencies[updatedModel.currency] = updatedModel
                }.disposed(by: disposeBag)
            
            // 검색어/즐겨찾기 상태 변경될 때마다 데이터 필터링/정렬
            Observable.merge(
                searchTextRelay.asObservable(),
                action.favoriteCurrency.map { _ in searchTextRelay.value }
            )
            .subscribe(with: self) { owner, searchText in
                /*
                 UX 고민
                 - 국가명을 검색할 때는 글자가 포함되기만 해도 결과에 포함되도록 구현
                 - ex) "레일리아" 검색 ➡️ "오스트레일리아" 결과 포함
                 */
                let filteredCurrencies = owner.allCurrencies.values.filter {
                    $0.currency.hasPrefix(searchText.uppercased()) ||
                    $0.country.lowercased().contains(searchText.lowercased())
                }.sorted {
                    if $0.isFavorite == $1.isFavorite {
                        return $0.currency < $1.currency
                    }
                    return $0.isFavorite == true
                }
                os_log("filteredCurrencies.count: %d", log: owner.log, type: .debug, filteredCurrencies.count)
                owner.state.filteredCurrencies?(filteredCurrencies)
                
                // 검색 결과가 없을 경우 "검색 결과 없음" 표시
                let isHidden = searchText.isEmpty == true || filteredCurrencies.isEmpty == false
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
                let currencies = exchangeRate.rates.map {
                    let country = self.currencyMap[$0.key] ?? ""
                    return CurrencyModel(currency: $0.key, country: country, rate: $0.value)
                }
                allCurrencies = Dictionary(uniqueKeysWithValues: currencies.map { ($0.currency, $0) })
                let filteredCurrencies = allCurrencies.values.sorted(by: { $0.currency < $1.currency })
                state.filteredCurrencies?(filteredCurrencies)
                state.needToShowAlert?(false)
                
            case .failure(_):
                allCurrencies = [:]
                state.filteredCurrencies?([])
                state.needToShowAlert?(true)
            }
        }
    }
}
