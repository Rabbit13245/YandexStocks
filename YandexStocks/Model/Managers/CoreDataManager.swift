//
//  CoreDataManager.swift
//  YandexStocks
//
//  Created by Admin on 3/25/21.
//

import CoreData

class CoreDataManager {
    // MARK: - Singletion
    private static var instance: CoreDataManager?
    static var shared: CoreDataManager {
        guard let instance = instance else {
            let newInstance = CoreDataManager()
            self.instance = newInstance
            return newInstance
        }
        return instance
    }
    private init() {}
    
    // MARK: - Private
    private let modelName = "YandexStocks"
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: modelName)
        container.loadPersistentStores { (_, error) in
            if let error = error {
                assertionFailure(error.localizedDescription)
            }
            
            container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
            container.viewContext.automaticallyMergesChangesFromParent = true
        }
        return container
    }()
    
    // MARK: - Public
    func saveInBackground(_ block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask { (context) in
            context.automaticallyMergesChangesFromParent = true
            context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
            block(context)
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    assertionFailure(error.localizedDescription)
                }
            }
        }
    }
    
    func removeObject(_ object: NSManagedObject) {
        persistentContainer.performBackgroundTask { (context) in
            context.automaticallyMergesChangesFromParent = true
            do {
                let removeObject = try context.existingObject(with: object.objectID)
                context.delete(removeObject)
                if context.hasChanges {
                    try context.save()
                }
            } catch {
                assertionFailure(error.localizedDescription)
            }
        }
    }
    
    func fetchEntities(withName name: String,
                       withPredicate predicate: NSPredicate? = nil) -> [NSManagedObject]? {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: name)
        fetchRequest.predicate = predicate
        
        return try? persistentContainer.viewContext.fetch(fetchRequest)
    }
}
