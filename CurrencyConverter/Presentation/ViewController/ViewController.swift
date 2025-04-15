//
//  ViewController.swift
//  CurrencyConverter
//
//  Created by 서동환 on 4/15/25.
//

import UIKit
import RxSwift
import SnapKit
import Then

import SwiftUI  // PreviewProvider 용도

final class ViewController: UIViewController {
    
    // MARK: - UI Components
    
    private lazy var currencyTableView = CurrencyTableView(frame: .zero, style: .plain).then {
        $0.delegate = self
        $0.dataSource = self
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        
        setupUI()
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
            $0.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
}

extension ViewController: UITableViewDelegate {
    
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CurrencyTableViewCell.identifier, for: indexPath)
        
        return cell
    }
}


// MARK: - PreviewProvider

struct Preview: PreviewProvider {
    static var previews: some View {
        // Preview를 보고자 하는 ViewController를 넣으면 됩니다.
        ViewController().toPreview()
    }
}
