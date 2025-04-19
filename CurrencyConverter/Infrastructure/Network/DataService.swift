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
    
    func loadData(completion: @escaping (Result<Currency, Error>) -> Void) {
        networkService.fetchData { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let data):
                do {
                    let currency = try JSONDecoder().decode(Currency.self, from: data)
                    os_log("currency: %@", log: self.log, type: .debug, "\(currency)")
                    completion(.success(currency))
                } catch {
                    let message = DataError.parsingFailed.rawValue + ": \(error)"
                    os_log("%@: %@", log: self.log, type: .error, message)
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
