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
    
    private let viewModel: ConverterViewModel
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    private let converterView = ConverterView()
    
    // MARK: - Initializer
    
    init(viewModel: ConverterViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "환율 계산기"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.view.backgroundColor = .systemBackground
        
        setupUI()
        bind()
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
            if !message.isEmpty {
                AlertHelper.showAlert(title: "오류", message: message, over: self)
            }
        }
        
        viewModel.state.code = { [weak self] code in
            self?.converterView.codeLabel.text = code
        }
        
        viewModel.state.country = { [weak self] country in
            self?.converterView.countryLabel.text = country
        }
        
        // 입력값에 따라 계산된 환율 표시
        viewModel.state.convertedResult = { [weak self] result in
            self?.converterView.resultLabel.text = result
        }
        
        // Action ➡️ ViewModel
        let action = ConverterViewModel.Action(
            buttonTapped: converterView.convertButton.rx.tap.asObservable(),
            amountText: converterView.amountTextField.rx.text.orEmpty.asObservable(),
            didBinding: Observable.just(())
        )
        viewModel.action?(action)
    }
}

// MARK: - PreviewProvider

#if DEBUG
import SwiftUI

struct ConverterViewControllerPreview: PreviewProvider {
    static var previews: some View {
        let mockCurrency = Currency(code: "XCG", country: "가상통화 (Crypto Generic)", difference: 0.0, rate: 1.7900, isFavorite: false)
        let converterVM = ConverterViewModel(currency: mockCurrency)
        
        // {뷰 컨트롤러 인스턴스}.toPreview()
        ConverterViewController(viewModel: converterVM).toPreview()
    }
}
#endif
