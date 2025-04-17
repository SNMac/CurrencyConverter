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
    
    // MARK: - UI Components
    
    private let converterView = ConverterView()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "환율 계산기"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.view.backgroundColor = .systemBackground
        
        setupUI()
    }
    
    // MARK: - Initializer
    
    init(converterModel: ConverterModel) {
        super.init(nibName: nil, bundle: nil)
        converterView.configure(converterModel: converterModel)
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
}

// MARK: - PreviewProvider

#if DEBUG
import SwiftUI

struct ConverterViewControllerPreview: PreviewProvider {
    static var previews: some View {
        // {뷰 컨트롤러 인스턴스}.toPreview()
        let model = ConverterModel(currency: "XCG", country: "가상통화 (Crypto Generic)")
        ConverterViewController(converterModel: model).toPreview()
    }
}
#endif
