//
//  DataService.swift
//  CurrencyConverter
//
//  Created by 서동환 on 4/15/25.
//

import Foundation
import OSLog

final class DataService {
    
    // MARK: - Properties
    
    private let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "DataService")
    
    private let networkService = NetworkService()
    
    enum DataError: String, Error {
        case fileNotFound = "JSON 파일 없음"
        case parsingFailed = "JSON 파싱 에러"
    }
    
    // MARK: - Methods
    
    func loadData(completion: @escaping (Result<ExchangeRate, Error>) -> Void) {
        networkService.fetchData { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let data):
                /* ---------- 상승 하락 테스트 코드 ---------- */
//                guard let path = Bundle.main.path(forResource: "mock", ofType: "json") else {
//                    os_log("🚨 JSON 파일을 찾을 수 없음", log: self.log, type: .error)
//                    completion(.failure(DataError.fileNotFound))
//                    return
//                }
//                do {
//                    let data = try Data(contentsOf: URL(fileURLWithPath: path))
//                    let exchangeRateDTO = try JSONDecoder().decode(ExchangeRateDTO.self, from: data)
//                    completion(.success(exchangeRateDTO.toDomain()))
                /* ---------- 상승 하락 테스트 코드 ---------- */
                
                do {
                    let exchangeRateDTO = try JSONDecoder().decode(ExchangeRateDTO.self, from: data)
                    os_log("exchangeRate: %@", log: log, type: .debug, "\(exchangeRateDTO)")
                    completion(.success(exchangeRateDTO.toDomain()))
                } catch {
                    let message = DataError.parsingFailed.rawValue + ": \(error)"
                    os_log("%@", log: log, type: .error, message)
                    completion(.failure(DataError.parsingFailed))
                }
                
            case .failure(_):
                let message = DataError.fileNotFound.rawValue
                os_log("%@", log: self.log, type: .error, message)
                completion(.failure(DataError.fileNotFound))
            }
        }
    }
}
