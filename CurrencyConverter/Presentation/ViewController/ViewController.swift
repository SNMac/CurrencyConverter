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
    
    private lazy var currencyTableView = CurrencyTableView(frame: .zero).then {
        $0.delegate = self
        $0.dataSource = self
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] cellCount in
                self?.cellCount = cellCount
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {
    
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CurrencyCell.identifier, for: indexPath)
        
        return cell
    }
}

// MARK: - PreviewProvider

struct Preview: PreviewProvider {
    static var previews: some View {
        // {뷰 컨트롤러 이름}().toPreview()
        ViewController().toPreview()
    }
}
