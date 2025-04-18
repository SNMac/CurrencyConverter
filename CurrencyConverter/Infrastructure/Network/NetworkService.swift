//
//  NetworkService.swift
//  CurrencyConverter
//
//  Created by 서동환 on 4/15/25.
//

import Foundation
import OSLog

final class NetworkService {
    
    // MARK: - Properties
    
    private let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "NetworkService")
    
    enum NetworkError: String, Error {
        case invalidURL = "유효하지 않은 URL"
        case noData = "데이터 없음"
        case requestFailed = "요청 실패"
    }
    
    // MARK: - Methods
    
    func fetchData(completion: @escaping (Result<Data, Error>) -> Void) {
//        guard let url: URL = URL(string: "https://open.er-api.com/v6/latest/TESTING") else {  // Alert 테스트
        guard let url: URL = URL(string: "https://open.er-api.com/v6/latest/USD") else {
            let message = NetworkError.invalidURL.rawValue
            os_log("%@", log: self.log, type: .error, message)
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let urlSession: URLSession = URLSession(configuration: .default)
        urlSession.dataTask(with: request) { data, response, error in
            let successRange: Range = (200..<300)
            
            guard let data, error == nil else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            if let response: HTTPURLResponse = response as? HTTPURLResponse {
                os_log("status code: %d", log: self.log, type: .debug, response.statusCode)
                
                if successRange.contains(response.statusCode) {
                    os_log("data: %@", log: self.log, type: .debug, "\(data)")
                    completion(.success(data))
                    
                } else {
                    let message = NetworkError.requestFailed.rawValue
                    os_log("%@", log: self.log, type: .error, message)
                    completion(.failure(NetworkError.requestFailed))
                }
            }
        }.resume()
    }
}
