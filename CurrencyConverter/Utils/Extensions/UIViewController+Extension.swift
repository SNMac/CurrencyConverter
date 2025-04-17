//
//  UIViewController+Extension.swift
//  CurrencyConverter
//
//  Created by 서동환 on 4/15/25.
//

import SwiftUI

#if DEBUG
extension UIViewController {
    private struct Preview: UIViewControllerRepresentable {
        let viewController: UIViewController
        
        func makeUIViewController(context: Context) -> UIViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        }
    }
    
    func toPreview() -> some View {
        Preview(viewController: self)
    }
}
#endif

/* 사용법
 #if DEBUG
 import SwiftUI

 struct ConverterViewControllerPreview: PreviewProvider {
     static var previews: some View {
         // {뷰 컨트롤러 인스턴스}.toPreview()
         ConverterViewController().toPreview()
     }
 }
 #endif
 */
