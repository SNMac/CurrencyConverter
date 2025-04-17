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
        let amountText: ControlProperty<String>
        let rate: Observable<Double>
    }
    
    // MARK: - Data ➡️ Output
    
    struct Output {
        /// 변환된 환율
        let convertedCurrency: Signal<Double>
    }
}

// MARK: - Methods

extension ConverterViewModel {
    func transform(input: Input) -> Output {
        // 버튼이 눌렸을 때 amountText와 rate의 최신값을 가져옴
        let convertedCurrency = input.buttonTapped
            .withLatestFrom(Observable.combineLatest(input.amountText, input.rate))
            .map { amountText, rate in
                let amount = Double(amountText) ?? 0.0
                return amount * rate
            }
            .asSignal(onErrorJustReturn: 0.0)
        
        return Output(convertedCurrency: convertedCurrency)
    }
}
