//
//  ViewModelProtocol.swift
//  CurrencyConverter
//
//  Created by 서동환 on 4/18/25.
//

import Foundation

protocol ViewModelProtocol {
    associatedtype Action
    associatedtype State
    
    var action: ((Action) -> Void)? { get }
    var state: State { get }
}
