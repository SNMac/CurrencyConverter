//
//  ConverterViewController.swift
//  CurrencyConverter
//
//  Created by 서동환 on 4/17/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

final class ConverterViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel = ConverterViewModel()
    private let disposeBag = DisposeBag()
    
    private let currencyModel: CurrencyModel
    
    // MARK: - UI Components
    
    private let converterView = ConverterView()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "환율 계산기"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.view.backgroundColor = .systemBackground
        
        setupUI()
        bind()
    }
    
    // MARK: - Initializer
    
    init(currencyModel: CurrencyModel) {
        self.currencyModel = currencyModel
        super.init(nibName: nil, bundle: nil)
        
        converterView.configure(currencyModel: currencyModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UI Methods

private extension ConverterViewController {
    func setupUI() {
        setViewHierarchy()
        setConstraints()
    }
    
    func setViewHierarchy() {
        self.view.addSubview(converterView)
    }
    
    func setConstraints() {
        converterView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func bind() {
        // ViewModel ➡️ State
        // 잘못된 입력값 Alert 처리
        viewModel.state.alertMessage = { [weak self] message in
            guard let self else { return }
            if message != "" {
                AlertHelper.showAlert(title: "오류", message: message, over: self)
            }
        }
        
        // 입력값에 따라 계산된 환율 표시
        viewModel.state.convertedResult = { [weak self] result in
            self?.converterView.resultLabel.text = result
        }
        
        // Action ➡️ ViewModel
        let action = ConverterViewModel.Action(
            buttonTapped: converterView.convertButton.rx.tap.asObservable(),
            currency: Observable.just(currencyModel.currency),
            amountText: converterView.amountTextField.rx.text.orEmpty.asObservable(),
            rate: Observable.just(currencyModel.rate)
        )
        viewModel.action?(action)
    }
}

// MARK: - PreviewProvider

#if DEBUG
import SwiftUI

struct ConverterViewControllerPreview: PreviewProvider {
    static var previews: some View {
        // {뷰 컨트롤러 인스턴스}.toPreview()
        let model = CurrencyModel(currency: "XCG", country: "가상통화 (Crypto Generic)", rate: 1.7900)
        ConverterViewController(currencyModel: model).toPreview()
    }
}
#endif
