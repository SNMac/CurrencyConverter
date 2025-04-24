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
    
    private let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "CoreDataManager")
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CurrencyConverter")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return container
    }()
    
    private var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private lazy var backgroundContext: NSManagedObjectContext = {
        let context = persistentContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()
    
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
    
    /// Core Data 비동기 작업
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        backgroundContext.perform {
            block(self.backgroundContext)
        }
    }
}

// MARK: - ExchangeRate CRUD Methods

extension CoreDataManager {
    /// ExchangeRate을 매개변수로 받아 ExchangeRateEntity로 변환 후 Core Data에 저장합니다.
    func saveExchangeRate(of exchangeRate: ExchangeRate) {
        performBackgroundTask { context in
            let exchangeRateEntity = ExchangeRateEntity(context: context)
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
                os_log("CoreDataManager) ExchangeRateEntity saved", log: CoreDataManager.shared.log, type: .debug)
                
            } catch {
                let msg = error.localizedDescription
                os_log("error: %@", log: CoreDataManager.shared.log, type: .error, msg)
            }
        }
    }
    
    /// Core Data에 저장되어있는 ExchangeRateEntity를 ExchangeRate로 변환 후 반환합니다.
    func fetchExchangeRate() -> ExchangeRate? {
        let fetchRequest = NSFetchRequest<ExchangeRateEntity>.init(entityName: "ExchangeRateEntity")
        
        do {
            guard let exchangeRateEntity = try context.fetch(fetchRequest).first else { return nil }
            os_log("CoreDataManager) ExchangeRateEntity fetched", log: CoreDataManager.shared.log, type: .debug)
            return exchangeRateEntity.toDomain()
            
        } catch {
            let msg = error.localizedDescription
            os_log("error: %@", log: CoreDataManager.shared.log, type: .error, msg)
            return nil
        }
    }
    
    /// ExchangeRate를 매개변수로 받아 CoreData에서 ExchangeRateEntity를 업데이트합니다.
    func updateExchangeRate(of exchangeRate: ExchangeRate, completion: @escaping () -> Void) {
        performBackgroundTask { context in
            let fetchRequest = NSFetchRequest<ExchangeRateEntity>.init(entityName: "ExchangeRateEntity")
            
            do {
                guard let exchangeRateEntity = try context.fetch(fetchRequest).first else { return }
                exchangeRateEntity.lastUpdatedUnix = exchangeRate.lastUpdatedUnix
                exchangeRateEntity.baseCode = exchangeRate.baseCode
                
                for currency in exchangeRate.currencies {
                    if let currencyEntity = CoreDataManager.shared.fetchCurrencyEntity(code: currency.code, in: context) {
                        currencyEntity.difference = currency.rate - currencyEntity.rate
                        currencyEntity.rate = currency.rate
                    }
                }
                try context.save()
                DispatchQueue.main.async { completion() }
                os_log("CoreDataManager) ExchangeRateEntity updated", log: CoreDataManager.shared.log, type: .debug)
                
            } catch {
                let msg = error.localizedDescription
                os_log("error: %@", log: CoreDataManager.shared.log, type: .error, msg)
            }
        }
    }
    
    /// CoreData에서 code에 해당하는 CurrencyEntity의 isFavorite을 업데이트합니다.
    func updateIsFavorite(code: String, isFavorite: Bool) {
        performBackgroundTask { context in
            guard let currencyEntity = CoreDataManager.shared.fetchCurrencyEntity(code: code, in: context) else { return }
            currencyEntity.isFavorite = isFavorite
            
            do {
                try context.save()
                os_log("CoreDataManager) CurrencyEntity updated: %@", log: CoreDataManager.shared.log, type: .debug, "\(currencyEntity.toDomain())")
                
            } catch {
                let msg = error.localizedDescription
                os_log("error: %@", log: CoreDataManager.shared.log, type: .error, msg)
            }
        }
    }
    
    /// Core Data에서 code에 해당하는 CurrencyEntity를 반환합니다.(context는 비동기 작업을 위한 매개변수)
    func fetchCurrencyEntity(code: String, in context: NSManagedObjectContext) -> CurrencyEntity? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "CurrencyEntity")
        fetchRequest.predicate = NSPredicate(format: "code = %@", code)
        
        do {
            let result = try context.fetch(fetchRequest)
            return result.first as? CurrencyEntity
            
        } catch {
            let msg = error.localizedDescription
            os_log("error: %@", log: CoreDataManager.shared.log, type: .error, msg)
            
            return nil
        }
    }
}

// MARK: - LastConverter CRUD Methods

extension CoreDataManager {
    /// LastConverterEntity를 생성하고, 인자로 받은 Currency에 해당하는 CurrencyEntity와 연결 후 Core Data에 저장합니다.
    func saveLastConverter(currencyCode: String) {
        performBackgroundTask { context in
            let lastConverterEntity = LastConverterEntity(context: context)
            let currencyEntity = CoreDataManager.shared.fetchCurrencyEntity(code: currencyCode, in: context)
            lastConverterEntity.currency = currencyEntity
            currencyEntity?.lastConverter = lastConverterEntity
            
            do {
                try context.save()
                os_log("CoreDataManager) LastConverterEntity saved: %@", log: CoreDataManager.shared.log, type: .debug, currencyCode)
                
            } catch {
                let msg = error.localizedDescription
                os_log("error: %@", log: CoreDataManager.shared.log, type: .error, msg)
            }
        }
    }
    
    /// Core Data에서 LastConverterEntity와 연결된 CurrencyEntity를 Currency로 변환 후 반환합니다.
    func fetchLastConverter() -> Currency? {
        let fetchRequest = NSFetchRequest<LastConverterEntity>.init(entityName: "LastConverterEntity")
        
        do {
            guard let lastConverterEntity = try context.fetch(fetchRequest).first else { return nil }
            os_log("CoreDataManager) LastConverterEntity fetched", log: CoreDataManager.shared.log, type: .debug)
            return lastConverterEntity.currency?.toDomain()
            
        } catch {
            let msg = error.localizedDescription
            os_log("error: %@", log: CoreDataManager.shared.log, type: .error, msg)
            return nil
        }
    }
    
    /// Core Data에서 LastConverterEntity를 삭제합니다.
    func deleteLastConverter() {
        performBackgroundTask { context in
        let fetchRequest = NSFetchRequest<LastConverterEntity>.init(entityName: "LastConverterEntity")
            
            do {
                let results = try context.fetch(fetchRequest)
                results.forEach { context.delete($0) }
                try context.save()
                os_log("CoreDataManager) LastConverterEntity deleted", log: CoreDataManager.shared.log, type: .debug)
            } catch {
                let msg = error.localizedDescription
                os_log("error: %@", log: CoreDataManager.shared.log, type: .error, msg)
            }
        }
    }
}
