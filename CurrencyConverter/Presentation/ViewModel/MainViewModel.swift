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
    private var allCurrencies = [CurrencyModel]()
    /// 필터링된(=보여지는) 환율 데이터
    private var filteredCurrencies = [CurrencyModel]()
    
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
            
            // 검색에 따라 데이터 필터링
            action.searchText
                .subscribe(with: self) { owner, searchText in
                    /*
                     UX 고민
                     - 국가명을 검색할 때는 글자가 포함되기만 해도 결과에 포함되도록 구현
                     - ex) "레일리아" 검색 ➡️ "오스트레일리아" 결과 포함
                     */
                    owner.filteredCurrencies = owner.allCurrencies.filter {
                        $0.currency.hasPrefix(searchText.uppercased()) ||
                        $0.country.lowercased().contains(searchText.lowercased())
                    }.sorted(by: { $0.isFavorite == true || $0.currency < $1.currency })
                    os_log("filteredCurrencies.count: %d", log: owner.log, type: .debug, owner.filteredCurrencies.count)
                    owner.state.filteredCurrencies?(owner.filteredCurrencies)
                    
                    // 검색 결과가 없을 경우 "검색 결과 없음" 표시
                    if searchText.isEmpty == true || owner.filteredCurrencies.isEmpty == false {
                        owner.state.isHiddenEmptyLabel?(true)
                    } else {
                        owner.state.isHiddenEmptyLabel?(false)
                    }
                }.disposed(by: disposeBag)
            
            action.favoriteCurrency
                .subscribe(with: self) { owner, model in
                    
                    os_log("favoriteCurrency: %@", log: owner.log, type: .debug, "\(model)")
                }.disposed(by: disposeBag)
            
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
            case .success(let currency):
                allCurrencies = currency.rates.map {
                    let country = self.currencyMap[$0.key] ?? ""
                    return CurrencyModel(currency: $0.key, country: country, rate: $0.value)
                }.sorted(by: { $0.currency < $1.currency })
                filteredCurrencies = allCurrencies
                state.filteredCurrencies?(allCurrencies)
                state.needToShowAlert?(false)
                
            case .failure(_):
                allCurrencies = []
                filteredCurrencies = []
                state.filteredCurrencies?([])
                state.needToShowAlert?(true)
            }
        }
    }
}
