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
    
    private let currency: Currency
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Action ➡️ Input
    
    struct Action {
        /// 버튼 눌렸을 때 발생하는 이벤트
        let buttonTapped: Observable<Void>
        /// 사용자의 입력값(USD)
        let amountText: Observable<String>
        /// 바인딩 완료 알림
        let didBinding: Observable<Void>
    }
    var action: ((Action) -> Void)?
    
    // MARK: - Output ➡️ State
    
    struct State {
        /// Alert에 표시할 메시지
        var alertMessage: ((String) -> Void)?
        /// 통화 코드
        var code: ((String) -> Void)?
        /// 국가명
        var country: ((String) -> Void)?
        /// 변환된 환율
        var convertedResult: ((String) -> Void)?
    }
    var state: State
    
    // MARK: - Initializer
    
    init(currency: Currency) {
        self.currency = currency
        
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
                .withLatestFrom(action.amountText)
                .filter({ !$0.isEmpty && Double($0) != nil })
                .map { amountText in
                    let amount = Double(amountText) ?? 0.0
                    let showingAmount = String(format: "%.2f", amount)
                    let showingConverted = String(format: "%.2f", amount * currency.rate)
                    return "$\(showingAmount) → \(showingConverted) \(currency)"
                }.bind(with: self) { owner, result in
                    owner.state.convertedResult?(result)
                }.disposed(by: disposeBag)
            
            // 바인딩 완료 이후) 화면에 표시할 데이터 전송
            action.didBinding
                .bind(with: self) { owner, _ in
                    owner.state.code?(currency.code)
                    owner.state.country?(currency.country)
                }.disposed(by: disposeBag)
        }
    }
}
