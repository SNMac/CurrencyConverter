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

final class ConverterViewModel {
    
    // MARK: - Properties
    
    private let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "CurrencyViewModel")
    
    private let disposeBag = DisposeBag()
    
    // MARK: - User Action ➡️ Input
    
    struct Input {
        /// 버튼 눌렸을 때 발생하는 이벤트
        let buttonTapped: ControlEvent<Void>
        /// 통화 코드
        let currency: Observable<String>
        /// 사용자의 입력값(USD)
        let amountText: ControlProperty<String>
        /// 통화 코드에 따른 환율
        let rate: Observable<Double>
    }
    
    // MARK: - Data ➡️ Output
    
    struct Output {
        /// Alert에 표시할 메시지
        let alertMessage: Signal<String>
        /// 변환된 환율
        let convertedResult: Signal<String>
    }
}

// MARK: - Methods

extension ConverterViewModel {
    func transform(input: Input) -> Output {
        // 버튼이 눌렸을 때) 잘못된 입력값 Alert 처리
        let alertMessage = input.buttonTapped
            .withLatestFrom(input.amountText)
            .map { amountText in
                if amountText.isEmpty {
                    return "금액을 입력해주세요"
                } else if Double(amountText) == nil {
                    return "올바른 숫자를 입력해주세요"
                } else {
                    return ""
                }
            }.asSignal(onErrorJustReturn: "")
        
        // 버튼이 눌렸을 때) 입력값에 따른 환율 계산
        let convertedResult = input.buttonTapped
            .withLatestFrom(Observable.combineLatest(input.currency, input.amountText, input.rate))
            .filter({ _, amountText, _ in
                !amountText.isEmpty && Double(amountText) != nil
            })
            .map { currency, amountText, rate in
                let amount = Double(amountText) ?? 0.0
                let converted = round(amount * rate * 100) / 100
                
                let showingAmount = String(format: "%.2f", amount)
                let showingConverted = String(format: "%.2f", converted)
                return "$\(showingAmount) → \(showingConverted) \(currency)"
            }.asSignal(onErrorJustReturn: "")
        
        return Output(alertMessage: alertMessage, convertedResult: convertedResult)
    }
}
