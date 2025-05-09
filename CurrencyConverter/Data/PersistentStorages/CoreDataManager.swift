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
}

// MARK: - ExchangeRate CRUD Methods

extension CoreDataManager {
    /// ExchangeRate을 매개변수로 받아 ExchangeRateEntity로 변환 후 Core Data에 저장합니다.
    func saveExchangeRate(of exchangeRate: ExchangeRate) {
        backgroundContext.perform { [weak self] in
            guard let self else { return }
            
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
                os_log(.debug, log: self.log, "CoreDataManager) ExchangeRateEntity saved")
                
            } catch {
                let msg = error.localizedDescription
                os_log(.error, log: self.log, "error: %@", msg)
            }
        }
    }
    
    /// Core Data에 저장되어있는 ExchangeRateEntity를 ExchangeRate로 변환 후 반환합니다.
    func fetchExchangeRate() -> ExchangeRate? {
        let fetchRequest = NSFetchRequest<ExchangeRateEntity>.init(entityName: "ExchangeRateEntity")
        
        do {
            guard let exchangeRateEntity = try context.fetch(fetchRequest).first else { return nil }
            os_log(.debug, log: log, "CoreDataManager) ExchangeRateEntity fetched")
            return exchangeRateEntity.toDomain()
            
        } catch {
            let msg = error.localizedDescription
            os_log(.error, log: log, "error: %@", msg)
            return nil
        }
    }
    
    /// ExchangeRate를 매개변수로 받아 CoreData에서 ExchangeRateEntity를 업데이트합니다.
    func updateExchangeRate(of exchangeRate: ExchangeRate, completion: @escaping () -> Void) {
        backgroundContext.perform { [weak self] in
            guard let self else { return }
            
            let fetchRequest = NSFetchRequest<ExchangeRateEntity>.init(entityName: "ExchangeRateEntity")
            
            do {
                guard let exchangeRateEntity = try context.fetch(fetchRequest).first else { return }
                exchangeRateEntity.lastUpdatedUnix = exchangeRate.lastUpdatedUnix
                exchangeRateEntity.baseCode = exchangeRate.baseCode
                
                for currency in exchangeRate.currencies {
                    if let currencyEntity = self.fetchCurrencyEntity(code: currency.code, in: context) {
                        currencyEntity.difference = currency.rate - currencyEntity.rate
                        currencyEntity.rate = currency.rate
                    }
                }
                try context.save()
                DispatchQueue.main.async { completion() }
                os_log(.debug, log: self.log, "CoreDataManager) ExchangeRateEntity updated")
                
            } catch {
                let msg = error.localizedDescription
                os_log(.error, log: self.log, "error: %@", msg)
            }
        }
    }
    
    /// CoreData에서 code에 해당하는 CurrencyEntity의 isFavorite을 업데이트합니다.
    func updateIsFavorite(code: String, isFavorite: Bool) {
        backgroundContext.perform { [weak self] in
            guard let self else { return }
            
            guard let currencyEntity = self.fetchCurrencyEntity(code: code, in: context) else { return }
            currencyEntity.isFavorite = isFavorite
            
            do {
                try context.save()
                os_log(.debug, log: self.log, "CoreDataManager) CurrencyEntity updated: %@", "\(currencyEntity.toDomain())")
                
            } catch {
                let msg = error.localizedDescription
                os_log(.error, log: self.log, "error: %@", msg)
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
            os_log(.error, log: log, "error: %@", msg)
            
            return nil
        }
    }
}

// MARK: - LastConverter CRUD Methods

extension CoreDataManager {
    /// LastConverterEntity를 생성하고, 인자로 받은 Currency에 해당하는 CurrencyEntity와 연결 후 Core Data에 저장합니다.
    func saveLastConverter(currencyCode: String) {
        backgroundContext.perform { [weak self] in
            guard let self else { return }
            
            let lastConverterEntity = LastConverterEntity(context: context)
            let currencyEntity = self.fetchCurrencyEntity(code: currencyCode, in: context)
            lastConverterEntity.currency = currencyEntity
            currencyEntity?.lastConverter = lastConverterEntity
            
            do {
                try context.save()
                os_log(.debug, log: self.log, "CoreDataManager) LastConverterEntity saved: %@", currencyCode)
                
                
            } catch {
                let msg = error.localizedDescription
                os_log(.error, log: self.log, "error: %@", msg)
            }
        }
    }
    
    /// Core Data에서 LastConverterEntity와 연결된 CurrencyEntity를 Currency로 변환 후 반환합니다.
    func fetchLastConverter() -> Currency? {
        let fetchRequest = NSFetchRequest<LastConverterEntity>.init(entityName: "LastConverterEntity")
        
        do {
            guard let lastConverterEntity = try context.fetch(fetchRequest).first else { return nil }
            os_log(.debug, log: log, "CoreDataManager) LastConverterEntity fetched")
            return lastConverterEntity.currency?.toDomain()
            
        } catch {
            let msg = error.localizedDescription
            os_log(.error, log: log, "error: %@", msg)
            return nil
        }
    }
    
    /// Core Data에서 LastConverterEntity를 삭제합니다.
    func deleteLastConverter() {
        backgroundContext.perform { [weak self] in
            guard let self else { return }
            
            let fetchRequest = NSFetchRequest<LastConverterEntity>.init(entityName: "LastConverterEntity")
            
            do {
                let results = try context.fetch(fetchRequest)
                results.forEach { self.context.delete($0) }
                try context.save()
                os_log(.debug, log: self.log, "CoreDataManager) LastConverterEntity deleted")
                
            } catch {
                let msg = error.localizedDescription
                os_log(.error, log: self.log, "error: %@", msg)
            }
        }
    }
}
