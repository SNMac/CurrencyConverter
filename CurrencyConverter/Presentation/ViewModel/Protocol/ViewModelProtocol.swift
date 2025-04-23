//
//  ViewModelProtocol.swift
//  CurrencyConverter
//
//  Created by 서동환 on 4/18/25.
//

import Foundation

protocol ViewModelProtocol {
    /// ViewModel Action ➡️ Input
    associatedtype Action
    /// ViewModel Output ➡️ State
    associatedtype State
    
    /// ViewModel에서 API 호출, 필터링, 환율 계산 등의 로직 처리 클로저 생성
    var action: ((Action) -> Void)? { get }
    /// ViewController에서 클로저로 바인딩
    var state: State { get }
}
