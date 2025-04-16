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

import SwiftUI  // PreviewProvider 용도

final class MainViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel = CurrencyViewModel()
    private var disposeBag = DisposeBag()
    
    private var cellCount: Int = 0
    
    // MARK: - UI Components
    
    private lazy var searchBar = UISearchBar().then {
        $0.delegate = self
        $0.searchBarStyle = .minimal
        $0.placeholder = "통화 검색"
    }
    
    private let currencyTableView = CurrencyTableView(frame: .zero)
    
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
        self.view.addSubviews(
            searchBar,
            currencyTableView
        )
    }
    
    func setConstraints() {
        // top = safeAreaLayoutGuide
        // leading, trailing = superView
        searchBar.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
        }
        
        // top = searchBar.bottom
        // leading, trailing, bottom = safeAreaLayoutGuide
        currencyTableView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom)
            $0.leading.trailing.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    func bind() {
        viewModel.cellCount
            .asDriver(onErrorJustReturn: 0)
            .drive(onNext: { [weak self] cellCount in
                self?.cellCount = cellCount
            })
            .disposed(by: disposeBag)
        
        viewModel.showingRates
            .asDriver(onErrorJustReturn: [:])
            .map({ return $0.sorted { $0.key < $1.key } })
            .drive(currencyTableView.rx.items(
                cellIdentifier: CurrencyCell.identifier,
                cellType: CurrencyCell.self)) { _, element, cell in
                cell.configure(
                    currency: element.key,
                    country: element.value.country,
                    rate: element.value.rate
                )
            }
            .disposed(by: disposeBag)
        
        viewModel.isErrorOccured
            .bind { [weak self] isError in
                if isError {
                    self?.showFailedToLoadAlert()
                }
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - Private Methods

private extension MainViewController {
    func showFailedToLoadAlert() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            let alert = UIAlertController(title: "오류", message: "데이터를 불러올 수 없습니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            self.present(alert, animated: true)
        }
    }
}

// MARK: - UISearchBarDelegate

extension MainViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        viewModel.searchCurrency(of: searchText)
    }
}

// MARK: - PreviewProvider

struct Preview: PreviewProvider {
    static var previews: some View {
        // {뷰 컨트롤러 인스턴스}.toPreview()
        MainViewController().toPreview()
    }
}
