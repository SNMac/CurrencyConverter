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
        let buttonTapped: ControlEvent<Void>
        let currency: Observable<String>
        let amountText: ControlProperty<String>
        let rate: Observable<Double>
    }
    
    // MARK: - Data ➡️ Output
    
    struct Output {
        /// 변환된 환율
        let alertMessage: Signal<String>
        let convertedResult: Signal<String>
    }
}

// MARK: - Methods

extension ConverterViewModel {
    func transform(input: Input) -> Output {
        // 잘못된 입력값 Alert 처리
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
        
        // 버튼이 눌렸을 때 amountText와 rate의 최신값을 가져옴
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
