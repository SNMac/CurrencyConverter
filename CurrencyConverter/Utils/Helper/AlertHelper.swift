//
//  AlertHelper.swift
//  CurrencyConverter
//
//  Created by 서동환 on 4/18/25.
//

import UIKit

class AlertHelper {
    static func showAlert(title: String?, message: String?, over viewController: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        viewController.present(alert, animated: true)
    }
}
