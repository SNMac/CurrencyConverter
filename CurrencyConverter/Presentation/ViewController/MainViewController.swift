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
    
    private let viewModel = CurrencyViewModel()
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    private let mainView = MainView()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
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
        let input = CurrencyViewModel.Input(searchText: mainView.currencySearchBar.rx.text.orEmpty)
        let output = viewModel.transform(input: input)
        
        // 데이터가 없는 경우 "데이터를 불러올 수 없습니다" Alert 표시
        output.isErrorOccurred
            .asDriver(onErrorJustReturn: false)
            .drive(with: self, onNext: { owner, isError in
                if isError {
                    owner.showFailedToLoadAlert()
                }
            })
            .disposed(by: disposeBag)
        
        // 검색 결과가 없을 경우 "검색 결과 없음" 표시
        let searchText = mainView.currencySearchBar.rx.text.orEmpty
        Observable.combineLatest(searchText, output.showingRates)
            .asDriver(onErrorJustReturn: ("", output.showingRates.value))
            .map { searchText, showingRates in
                searchText.isEmpty == true || showingRates.isEmpty == false
            }
            .drive(with: self) { owner, needToHide in
                owner.mainView.emptyStateLabel.isHidden = needToHide
            }
            .disposed(by: disposeBag)
        
        // CurrencyTableView에 데이터 표시
        output.showingRates
            .asDriver(onErrorJustReturn: [])
            .drive(mainView.currencyTableView.rx.items(
                cellIdentifier: CurrencyCell.identifier,
                cellType: CurrencyCell.self)) { _, element, cell in
                    cell.configure(currencyModel: element)
                }
                .disposed(by: disposeBag)
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

struct Preview: PreviewProvider {
    static var previews: some View {
        // {뷰 컨트롤러 인스턴스}.toPreview()
        MainViewController().toPreview()
    }
}
#endif
