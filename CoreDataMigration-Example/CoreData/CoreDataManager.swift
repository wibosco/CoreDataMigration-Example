//
//  CoreDataManager.swift
//  CoreDataMigration-Example
//
//  Created by William Boles on 11/09/2017.
//  Copyright © 2017 William Boles. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager {
    
    let fileManager: FileManager
    let migrator: CoreDataMigrator
    
    lazy var persistentContainer: NSPersistentContainer! = {
        let persistentContainer = NSPersistentContainer(name: "CoreDataMigration_Example")
        
        let url = self.fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).last!.appendingPathComponent("CoreDataMigration_Example.sqlite")
        let description = NSPersistentStoreDescription(url: url)
        description.shouldInferMappingModelAutomatically = false //inferred mapping will be handled else where
        
        persistentContainer.persistentStoreDescriptions = [description]
        
        return persistentContainer
    }()
    
    lazy var backgroundContext: NSManagedObjectContext = {
        let context = self.persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return context
    }()
    
    lazy var mainContext: NSManagedObjectContext = {
        let context = self.persistentContainer.viewContext
        context.automaticallyMergesChangesFromParent = true
        
        return context
    }()
    
    // MARK: - Singleton
    
    static let shared = CoreDataManager()
    
    // MARK: - Init
    
    init(fileManager: FileManager = FileManager.default, migrator: CoreDataMigrator = CoreDataMigrator()) {
        self.fileManager = fileManager
        self.migrator = migrator
    }
    
    // MARK: - SetUp
    
    func setup(completion: @escaping () -> Void) {
        loadPersistentStore {
            completion()
        }
    }
    
    // MARK: - Loading
    
    private func loadPersistentStore(completion: @escaping () -> Void) {
        migrateStoreIfNeeded {
            self.persistentContainer.loadPersistentStores { description, error in
                guard error == nil else {
                    fatalError("was unable to load store")
                }
                
                completion()
            }
        }
    }
    
    private func migrateStoreIfNeeded(completion: @escaping () -> Void) {
        let storeLocation = persistentContainer.persistentStoreDescriptions[0].url!
        if migrator.requiresMigration(storeLocation: storeLocation) {
            DispatchQueue.global(qos: .userInitiated).async {
                self.migrator.migrateStore(storeLocation: storeLocation)
                
                DispatchQueue.main.async {
                    completion()
                }
            }
        } else {
            DispatchQueue.main.async {
                completion()
            }
        }
    }
}

