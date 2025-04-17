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
        let input = ConverterViewModel.Input(
            buttonTapped: converterView.convertButton.rx.tap,
            amountText: converterView.amountTextField.rx.text.orEmpty,
            rate: Observable.just(currencyModel.rate)
        )
        let output = viewModel.transform(input: input)
        
        output.convertedCurrency
            .asDriver(onErrorJustReturn: 0.0)
            .drive(with: self) { owner, converted in
                owner.converterView.resultLabel.text = String(format: "%.4f", converted)
            }.disposed(by: disposeBag)
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
