//
//  DataService.swift
//  CurrencyConverter
//
//  Created by 서동환 on 4/15/25.
//

import Foundation
import OSLog

final class DataService {
    private let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "DataService")
    
    private let networkService = NetworkService()
    
    enum DataError: Error {
        case fileNotFound
        case parsingFailed
    }
    
    func loadCurrency(completion: @escaping (Result<Currency, Error>) -> Void) {
        networkService.fetchData { data in
            guard let data else {
                os_log("JSON 파일을 찾을 수 없음", log: self.log, type: .error)
                completion(.failure(DataError.fileNotFound))
                return
            }
            
            do {
                let currency = try JSONDecoder().decode(Currency.self, from: data)
                os_log("currency: %@", log: self.log, type: .debug, "\(currency)")
                completion(.success(currency))
            } catch {
                let errorString = "\(error)"
                os_log("JSON 파싱 에러 : $@", log: self.log, type: .error, errorString)
                completion(.failure(DataError.parsingFailed))
            }
        }
    }
}
