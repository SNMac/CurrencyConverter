//
//  ViewController.swift
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

final class ViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel = CurrencyViewModel()
    private var disposeBag = DisposeBag()
    
    private var cellCount: Int = 0
    
    // MARK: - UI Components
    
    private lazy var currencyTableView = CurrencyTableView(frame: .zero)
    
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

private extension ViewController {
    func setupUI() {
        setViewHierarchy()
        setConstraints()
    }
    
    func setViewHierarchy() {
        self.view.addSubview(currencyTableView)
    }
    
    func setConstraints() {
        currencyTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func bind() {
        viewModel.cellCount
            .asDriver(onErrorJustReturn: 0)
            .drive(onNext: { [weak self] cellCount in
                self?.cellCount = cellCount
            })
            .disposed(by: disposeBag)
        
        viewModel.rates
            .asDriver(onErrorJustReturn: [:])
            .map({ return $0.sorted { $0.key < $1.key } })
            .drive(currencyTableView.rx.items(
                cellIdentifier: CurrencyCell.identifier,
                cellType: CurrencyCell.self)) { _, element, cell in
                cell.configure(currencyCode: element.key, exchangeRate: element.value)
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

private extension ViewController {
    func showFailedToLoadAlert() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            let alert = UIAlertController(title: "오류", message: "데이터를 불러올 수 없습니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            self.present(alert, animated: true)
        }
    }
}

// MARK: - PreviewProvider

struct Preview: PreviewProvider {
    static var previews: some View {
        // {뷰 컨트롤러 인스턴스}.toPreview()
        ViewController().toPreview()
    }
}
