//
//  CoreDataStorage.swift
//  CurrencyConverter
//
//  Created by 서동환 on 4/22/25.
//

import UIKit
import CoreData
import OSLog

final class CoreDataStorage {
    
    static let shared = CoreDataStorage()
    
    private static let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "CoreDataManager")
    
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
        guard let entity = NSEntityDescription.entity(forEntityName: "ExchangeRateEntity", in: context) else { return }
        
        let currencyEntities = exchangeRate.currencies.map { currency -> CurrencyEntity in
            let currencyEntity = CurrencyEntity(context: context)
            currencyEntity.code = currency.code
            currencyEntity.country = currency.country
            currencyEntity.rate = currency.rate
            currencyEntity.difference = currency.difference
            currencyEntity.isFavorite = currency.isFavorite
            return currencyEntity
        }
        
        let object = ExchangeRateEntity(entity: entity, insertInto: context)
        object.lastUpdatedUnix = exchangeRate.lastUpdatedUnix
        object.baseCode = exchangeRate.baseCode
        object.currencies = NSSet(array: currencyEntities)
        
        do {
            try context.save()
        } catch {
            let msg = error.localizedDescription
            os_log("error: %@", log: CoreDataStorage.log, type: .error, msg)
        }
    }
    
    /// Core Data에 저장되어있는 ExchangeRateEntity를 ExchangeRate로 변환 후 반환합니다.
    func fetchData() -> ExchangeRate? {
        let fetchRequest = NSFetchRequest<ExchangeRateEntity>.init(entityName: "ExchangeRateEntity")
        
        do {
            guard let exchangeRateEntity = try context.fetch(fetchRequest).first else { return nil }
            return exchangeRateEntity.toDomain()
            
        } catch {
            let msg = error.localizedDescription
            os_log("error: %@", log: CoreDataStorage.log, type: .error, msg)
            return nil
        }
    }
    
    /// Currency을 매개변수로 받아 CoreData에서 해당하는 code의 데이터를 수정합니다.
    func updateData(currency: Currency) {
        do {
            guard let object = fetchEntity(code: currency.code) else { return }
            object.rate = currency.rate
            object.difference = currency.difference - object.difference
            object.isFavorite = currency.isFavorite
            try context.save()
            
        } catch {
            let msg = error.localizedDescription
            os_log("error: %@", log: CoreDataStorage.log, type: .error, msg)
        }
    }
    
    /// Core Data의 모든 데이터 삭제
    func deleteAllData() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "ExchangeRateEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
        } catch {
            let msg = error.localizedDescription
            os_log("error: %@", log: CoreDataStorage.log, type: .error, msg)
        }
    }
    
    /// 중복 코드 최적화용
    func fetchEntity(code: String) -> CurrencyEntity? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "CurrencyEntity")
        fetchRequest.predicate = NSPredicate(format: "code = %@", code)
        
        do {
            let result = try context.fetch(fetchRequest)
            return result.first as? CurrencyEntity
            
        } catch {
            let msg = error.localizedDescription
            os_log("error: %@", log: CoreDataStorage.log, type: .error, msg)
            
            return nil
        }
    }
}

