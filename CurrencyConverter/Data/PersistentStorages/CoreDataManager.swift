//
//  CoreDataManager.swift
//  CurrencyConverter
//
//  Created by 서동환 on 4/22/25.
//

import UIKit
import CoreData
import OSLog

final class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    private static let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "CoreDataStorage")
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CurrencyConverter")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    // MARK: - Core Data Saving support

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    /// ExchangeRate을 매개변수로 받아 ExchangeRateEntity로 변환 후 Core Data에 저장합니다.
    func saveData(exchangeRate: ExchangeRate) {
        
        let exchangeRateEntity: ExchangeRateEntity = .init(context: context)
        exchangeRateEntity.lastUpdatedUnix = exchangeRate.lastUpdatedUnix
        exchangeRateEntity.baseCode = exchangeRate.baseCode
        
        for currency in exchangeRate.currencies {
            let currencyEntity = CurrencyEntity(context: context)
            currencyEntity.code = currency.code
            currencyEntity.country = currency.country
            currencyEntity.difference = currency.rate - currencyEntity.rate
            currencyEntity.rate = currency.rate
            currencyEntity.isFavorite = currency.isFavorite
            currencyEntity.exchangeRate = exchangeRateEntity
            exchangeRateEntity.addToCurrencies(currencyEntity)
        }
        
        
        do {
            try context.save()
            os_log("CoreDataStorage) saved: %@", log: CoreDataManager.log, type: .debug, "\(exchangeRateEntity.toDomain())")
        } catch {
            let msg = error.localizedDescription
            os_log("error: %@", log: CoreDataManager.log, type: .error, msg)
        }
    }
    
    /// Core Data에 저장되어있는 ExchangeRateEntity를 ExchangeRate로 변환 후 반환합니다.
    func fetchData() -> ExchangeRate? {
        let fetchRequest = NSFetchRequest<ExchangeRateEntity>.init(entityName: "ExchangeRateEntity")
        
        do {
            guard let exchangeRateEntity = try context.fetch(fetchRequest).first else { return nil }
            os_log("CoreDataStorage) fetched", log: CoreDataManager.log, type: .debug)
            return exchangeRateEntity.toDomain()
            
        } catch {
            let msg = error.localizedDescription
            os_log("error: %@", log: CoreDataManager.log, type: .error, msg)
            return nil
        }
    }
    
    /// ExchangeRate를 매개변수로 받아 CoreData에서 모든 데이터를 업데이트합니다.
    func updateAllData(exchangeRate: ExchangeRate) {
        let fetchRequest = NSFetchRequest<ExchangeRateEntity>.init(entityName: "ExchangeRateEntity")
        
        do {
            guard let exchangeRateEntity = try context.fetch(fetchRequest).first else { return }
            exchangeRateEntity.lastUpdatedUnix = exchangeRate.lastUpdatedUnix
            exchangeRateEntity.baseCode = exchangeRate.baseCode
            
            for currency in exchangeRate.currencies {
                if let currencyEntity = fetchEntity(code: currency.code) {
                    currencyEntity.difference = currency.rate - currencyEntity.rate
                    currencyEntity.rate = currency.rate
                    exchangeRateEntity.addToCurrencies(currencyEntity)
                } else {
                    let currencyEntity: CurrencyEntity = .init(context: context)
                    currencyEntity.code = currency.code
                    currencyEntity.country = currency.country
                    currencyEntity.difference = currency.rate
                    currencyEntity.rate = currency.rate
                    exchangeRateEntity.addToCurrencies(currencyEntity)
                }
            }
            
            try context.save()
            os_log("CoreDataStorage) exchangeRate updated: %@", log: CoreDataManager.log, type: .debug, "\(exchangeRateEntity.toDomain())")
            
        } catch {
            let msg = error.localizedDescription
            os_log("error: %@", log: CoreDataManager.log, type: .error, msg)
        }
    }
    
    /// Currency 배열을 매개변수로 받아 CoreData에서 code에 해당하는 CurrencyEntity의 isFavorite를 수정합니다.
    func updateIsFavorite(currency: Currency) {
        guard let currencyEntity = fetchEntity(code: currency.code) else { return }
        currencyEntity.isFavorite = currency.isFavorite
        
        do {
            try context.save()
            os_log("CoreDataStorage) isFavorite updated: %@", log: CoreDataManager.log, type: .debug, "\(currencyEntity.toDomain())")
            
        } catch {
            let msg = error.localizedDescription
            os_log("error: %@", log: CoreDataManager.log, type: .error, msg)
        }
    }
    
    /// Core Data에서 code에 해당하는 CurrencyEntity 반환
    func fetchEntity(code: String) -> CurrencyEntity? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "CurrencyEntity")
        fetchRequest.predicate = NSPredicate(format: "code = %@", code)
        
        do {
            let result = try context.fetch(fetchRequest)
            return result.first as? CurrencyEntity
            
        } catch {
            let msg = error.localizedDescription
            os_log("error: %@", log: CoreDataManager.log, type: .error, msg)
            
            return nil
        }
    }
}
