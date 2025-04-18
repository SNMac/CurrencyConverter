//
//  ConverterViewModel.swift
//  CurrencyConverter
//
//  Created by 서동환 on 4/17/25.
//

import Foundation
import RxSwift
import RxRelay

final class ConverterViewModel: ViewModelProtocol {
    
    // MARK: - Properties
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Action ➡️ Input
    
    struct Action {
        /// 버튼 눌렸을 때 발생하는 이벤트
        let buttonTapped: Observable<Void>
        /// 통화 코드
        let currency: Observable<String>
        /// 사용자의 입력값(USD)
        let amountText: Observable<String>
        /// 통화 코드에 따른 환율
        let rate: Observable<Double>
    }
    var action: ((Action) -> Void)?
    
    // MARK: - Output ➡️ State
    
    struct State {
        /// Alert에 표시할 메시지
        var alertMessage: ((String) -> Void)?
        /// 변환된 환율
        var convertedResult: ((String) -> Void)?
    }
    var state: State
    
    // MARK: - Initializer
    
    init() {
        state = State()
        
        action = { [weak self] action in
            guard let self else { return }
            
            // 버튼이 눌렸을 때) 잘못된 입력값 Alert 처리
            action.buttonTapped
                .withLatestFrom(action.amountText)
                .map { amountText in
                    if amountText.isEmpty {
                        return "금액을 입력해주세요"
                    } else if Double(amountText) == nil {
                        return "올바른 숫자를 입력해주세요"
                    } else {
                        return ""
                    }
                }.bind(with: self) { owner, message in
                    owner.state.alertMessage?(message)
                }.disposed(by: disposeBag)
            
            // 버튼이 눌렸을 때) 입력값에 따른 환율 계산
            action.buttonTapped
                .withLatestFrom(Observable.combineLatest(action.currency, action.amountText, action.rate))
                .filter({ _, amountText, _ in
                    !amountText.isEmpty && Double(amountText) != nil
                })
                .map { currency, amountText, rate in
                    let amount = Double(amountText) ?? 0.0
                    let showingAmount = String(format: "%.2f", amount)
                    let showingConverted = String(format: "%.2f", amount * rate)
                    return "$\(showingAmount) → \(showingConverted) \(currency)"
                }.bind(with: self) { owner, result in
                    owner.state.convertedResult?(result)
                }.disposed(by: disposeBag)
        }
    }
}
