//
//  NetworkService.swift
//  CurrencyConverter
//
//  Created by 서동환 on 4/15/25.
//

import Foundation
import OSLog

final class NetworkService {
    private let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "NetworkService")
    
    func fetchData(completion: @escaping (Data?) -> Void) {
        guard let url: URL = URL(string: "https://open.er-api.com/v6/latest/USD") else {
            os_log("유효하지 않은 URL", log: self.log, type: .error)
            completion(nil)
            return
        }
        
        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let urlSession: URLSession = URLSession(configuration: .default)
        urlSession.dataTask(with: request) { data, response, error in
            let successRange: Range = (200..<300)
            
            guard let data, error == nil else {
                completion(nil)
                return
            }
            
            if let response: HTTPURLResponse = response as? HTTPURLResponse {
                os_log("status code: %d", log: self.log, type: .debug, response.statusCode)
                
                if successRange.contains(response.statusCode) {
                    os_log("data: %@", log: self.log, type: .debug, "\(data)")
                    completion(data)
                    
                } else {
                    os_log("요청 실패", log: self.log, type: .error)
                    completion(nil)
                }
            }
        }.resume()
    }
}
