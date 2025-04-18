//
//  ConverterViewModel.swift
//  CurrencyConverter
//
//  Created by 서동환 on 4/17/25.
//

import Foundation
import OSLog
import RxSwift
import RxRelay
import RxCocoa

final class ConverterViewModel: ViewModelProtocol {
    
    // MARK: - Properties
    
    private let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "CurrencyViewModel")
    
    private let disposeBag = DisposeBag()
    
    // MARK: - User Action ➡️ Input
    
//    struct Action {
//        /// 버튼 눌렸을 때 발생하는 이벤트
//        let buttonTapped: ControlEvent<Void>
//        /// 통화 코드
//        let currency: Observable<String>
//        /// 사용자의 입력값(USD)
//        let amountText: ControlProperty<String>
//        /// 통화 코드에 따른 환율
//        let rate: Observable<Double>
//    }
    
    struct Action {
        /// 통화 코드
        let currency: String
        /// 사용자의 입력값(USD)
        let amountText: String
        /// 통화 코드에 따른 환율
        let rate: Double
    }
    
    var action: ((Action) -> Void)?
    
    // MARK: - State ➡️ Output
    
//    struct State {
//        /// Alert에 표시할 메시지
//        let alertMessage: Signal<String>
//        /// 변환된 환율
//        let convertedResult: Signal<String>
//    }
//    
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
            var alertMessage = ""
            if action.amountText.isEmpty {
                alertMessage = "금액을 입력해주세요"
            } else if Double(action.amountText) == nil {
                alertMessage = "올바른 숫자를 입력해주세요"
            } else {
                alertMessage = ""
            }
            state.alertMessage?(alertMessage)
            
            // 버튼이 눌렸을 때) 입력값에 따른 환율 계산
            var convertedResult = ""
            if !action.amountText.isEmpty && Double(action.amountText) != nil {
                let amount = Double(action.amountText) ?? 0.0
                let converted = round(amount * action.rate * 100) / 100
                let currency = action.currency
                
                let showingAmount = String(format: "%.2f", amount)
                let showingConverted = String(format: "%.2f", converted)
                convertedResult = "$\(showingAmount) → \(showingConverted) \(currency)"
                state.convertedResult?(convertedResult)
            }
        }
    }
}

// MARK: - Methods

extension ConverterViewModel {
//    func transform(action: Action) -> State {
//        // 버튼이 눌렸을 때) 잘못된 입력값 Alert 처리
//        let alertMessage = action.buttonTapped
//            .withLatestFrom(action.amountText)
//            .map { amountText in
//                if amountText.isEmpty {
//                    return "금액을 입력해주세요"
//                } else if Double(amountText) == nil {
//                    return "올바른 숫자를 입력해주세요"
//                } else {
//                    return ""
//                }
//            }.asSignal(onErrorJustReturn: "")
//        
//        // 버튼이 눌렸을 때) 입력값에 따른 환율 계산
//        let convertedResult = action.buttonTapped
//            .withLatestFrom(Observable.combineLatest(action.currency, action.amountText, action.rate))
//            .filter({ _, amountText, _ in
//                !amountText.isEmpty && Double(amountText) != nil
//            })
//            .map { currency, amountText, rate in
//                let amount = Double(amountText) ?? 0.0
//                let converted = round(amount * rate * 100) / 100
//                
//                let showingAmount = String(format: "%.2f", amount)
//                let showingConverted = String(format: "%.2f", converted)
//                return "$\(showingAmount) → \(showingConverted) \(currency)"
//            }.asSignal(onErrorJustReturn: "")
//        
//        return State(alertMessage: alertMessage, convertedResult: convertedResult)
//    }
}
