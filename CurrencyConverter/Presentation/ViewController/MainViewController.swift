//
//  MainViewController.swift
//  CurrencyConverter
//
//  Created by 서동환 on 4/15/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

final class MainViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: MainViewModel
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    private let mainView = MainView()
    
    // MARK: - Initializer
    
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "환율 정보"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.view.backgroundColor = .systemBackground
        
        setupUI()
        bind()
    }
}

// MARK: - UI Methods

private extension MainViewController {
    func setupUI() {
        setViewHierarchy()
        setConstraints()
    }
    
    func setViewHierarchy() {
        self.view.addSubview(mainView)
    }
    
    func setConstraints() {
        mainView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func bind() {
        // ViewModel ➡️ State
        // 데이터가 없는 경우 "데이터를 불러올 수 없습니다" Alert 표시
        viewModel.state.needToShowAlert = { [weak self] isError in
            if isError {
                self?.showFailedToLoadAlert()
            }
        }
        
        // CurrencyTableView에 데이터 표시
        let sortedCurrencies = BehaviorRelay<[Currency]>(value: [])
        let favoriteCurrency = PublishRelay<Currency>()
        sortedCurrencies
            .asDriver()
            .drive(mainView.currencyTableView.rx.items(
                cellIdentifier: CurrencyCell.identifier,
                cellType: CurrencyCell.self)) { _, currency, cell in
                    cell.configure(currency: currency)
                    
                    // 즐겨찾기 버튼 바인딩
                    cell.favoriteButton.rx.tap
                        .asDriver()
                        .drive(onNext: {
                            favoriteCurrency.accept(currency)
                        })
                        .disposed(by: cell.disposeBag)
                }.disposed(by: disposeBag)
        viewModel.state.sortedCurrencies = { currencies in
            sortedCurrencies.accept(currencies)
        }
        
        // CurrencyTableView 셀 선택 시 ConverterViewController 표시
        let didPushConverterVC = PublishRelay<String>()
        mainView.currencyTableView.rx.modelSelected(Currency.self)
            .asDriver()
            .drive(with: self) { owner, currency in
                let currency = Currency(code: currency.code,
                                        country: currency.country,
                                        difference: currency.difference,
                                        rate: currency.rate,
                                        isFavorite: currency.isFavorite)
                let converterVC = ConverterViewController(viewModel: ConverterViewModel(currency: currency))
                converterVC.viewWillDisappearDelegate = self
                owner.navigationController?.pushViewController(converterVC, animated: true)
                didPushConverterVC.accept(currency.code)
            }.disposed(by: disposeBag)
        
        // 검색 결과가 없을 경우 "검색 결과 없음" 표시
        viewModel.state.needToHideEmptyLabel = { [weak self] isHidden in
            self?.mainView.emptyStateLabel.isHidden = isHidden
        }
        
        // Action ➡️ ViewModel
        let action = MainViewModel.Action(
            searchText: mainView.currencySearchBar.rx.text.orEmpty.asObservable(),
            favoriteCurrency: favoriteCurrency.asObservable(),
            didPushConverterVC: didPushConverterVC.asObservable(),
            didBinding: Observable.just(())
        )
        viewModel.action?(action)
    }
}

// MARK: - Private Methods

private extension MainViewController {
    func showFailedToLoadAlert() {
        AlertHelper.showAlert(title: "오류", message: "데이터를 불러올 수 없습니다.", over: self)
    }
}

// MARK: - ViewWillDisappearDelegate

extension MainViewController: ViewWillDisappearDelegate {
    func notifyViewWillDisappear() {
        viewModel.deleteLastConverterCoreData()
    }
}

// MARK: - PreviewProvider

#if DEBUG
import SwiftUI

struct MainViewControllerPreview: PreviewProvider {
    static var previews: some View {
        // {뷰 컨트롤러 인스턴스}.toPreview()
        MainViewController(viewModel: MainViewModel()).toPreview()
    }
}
#endif
