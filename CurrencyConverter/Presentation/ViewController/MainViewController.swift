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
    
    private let viewModel = MainViewModel()
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    private let mainView = MainView()
    
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
        let input = MainViewModel.Input(searchText: mainView.currencySearchBar.rx.text.orEmpty)
        let output = viewModel.transform(input: input)
        
        // 데이터가 없는 경우 "데이터를 불러올 수 없습니다" Alert 표시
        output.needToShowAlert
            .drive(with: self, onNext: { owner, isError in
                if isError {
                    owner.showFailedToLoadAlert()
                }
            }).disposed(by: disposeBag)
        
        // CurrencyTableView에 데이터 표시
        output.showingCurrencies
            .drive(mainView.currencyTableView.rx.items(
                cellIdentifier: CurrencyCell.identifier,
                cellType: CurrencyCell.self)) { _, model, cell in
                    cell.configure(currencyModel: model)
                }.disposed(by: disposeBag)
        
        // 검색 결과가 없을 경우 "검색 결과 없음" 표시
        output.isHiddenEmptyLabel
            .drive(with: self) { owner, isHidden in
                owner.mainView.emptyStateLabel.isHidden = isHidden
            }.disposed(by: disposeBag)
        
        // CurrencyTableView 셀 선택 시 ConverterViewController 표시
        Driver.zip(
            mainView.currencyTableView.rx.modelSelected(CurrencyModel.self).asDriver(),
            mainView.currencyTableView.rx.itemSelected.asDriver()
        )
        .drive(with: self, onNext: { owner, element in
            let (model, indexPath) = element
            owner.mainView.currencyTableView.deselectRow(at: indexPath, animated: true)
            
            let currencyModel = CurrencyModel(currency: model.currency, country: model.country, rate: model.rate)
            let converterVC = ConverterViewController(currencyModel: currencyModel)
            owner.navigationController?.pushViewController(converterVC, animated: true)
        }).disposed(by: disposeBag)
    }
}

// MARK: - Private Methods

private extension MainViewController {
    func showFailedToLoadAlert() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "오류", message: "데이터를 불러올 수 없습니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            self.present(alert, animated: true)
        }
    }
}

// MARK: - PreviewProvider

#if DEBUG
import SwiftUI

struct MainViewControllerPreview: PreviewProvider {
    static var previews: some View {
        // {뷰 컨트롤러 인스턴스}.toPreview()
        MainViewController().toPreview()
    }
}
#endif
