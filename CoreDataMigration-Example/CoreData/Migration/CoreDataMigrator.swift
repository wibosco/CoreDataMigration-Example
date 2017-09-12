//
//  CoreDataMigrator.swift
//  CoreDataMigration-Example
//
//  Created by William Boles on 11/09/2017.
//  Copyright © 2017 William Boles. All rights reserved.
//

import CoreData

/**
 Responsible for handling Core Data model migrations.
 
 The default Core Data model migration approach is to go from earlier version to all possible future versions.
 
 So, if we have 4 model versions (1, 2, 3, 4), you would need to create the following mappings 1 to 4, 2 to 4 and 3 to 4. 
 Then when we create model version 5, we would create mappings 1 to 5, 2 to 5, 3 to 5 and 4 to 5. You can see that for each 
 new version we must create new mappings from all previous versions to the current version. This does not scale well, in the
 above example 4 new mappings have been created. For each new version you must add n-1 new mappings.
 
 Instead the solution below uses an iterative approach where we migrate mutliple times through a chain of model versions.
 
 So, if we have 4 model versions (1, 2, 3, 4), you would need to create the following mappings 1 to 2, 2 to 3 and 3 to 4.
 Then when we create model version 5, we only need to create one additional mapping 4 to 5. This greatly reduces the work
 required when adding a new version.
 */
class CoreDataMigrator {
    
    // MARK: - Check
    
    func requiresMigration(storeLocation: URL, currentMigrationModel: CoreDataMigrationModel = CoreDataMigrationModel.current) -> Bool {
        guard let metadata = try? NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: NSSQLiteStoreType, at: storeLocation, options: nil) else {
            return false
        }
        
        return !currentMigrationModel.managedObjectModel().isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata)
    }
    
    // MARK: - Migration
    
    func migrateStore(storeLocation: URL) {
        migrateStore(from: storeLocation, to: storeLocation, targetVersion: CoreDataMigrationModel.current)
    }
    
    func migrateStore(from sourceURL: URL, to targetURL: URL, targetVersion: CoreDataMigrationModel) {
        guard let sourceMigrationVersionModel = CoreDataMigrationVersionSourceModel(storeURL: sourceURL as URL) else {
            fatalError("unknown store version at URL \(sourceURL)")
        }
        
        forceWALCheckpointing(storeLocation: sourceURL)
        
        var currentURL = sourceURL
        let migrationSteps = sourceMigrationVersionModel.migrationSteps(to: targetVersion)
        
        for step in migrationSteps {
            let manager = NSMigrationManager(sourceModel: step.source, destinationModel: step.destination)
            let destinationURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent(UUID().uuidString)
            
            try! manager.migrateStore(from: currentURL, sourceType: NSSQLiteStoreType, options: nil, with: step.mapping, toDestinationURL: destinationURL, destinationType: NSSQLiteStoreType, destinationOptions: nil)
            
            if currentURL != sourceURL {
                //Destroy intermediate step's store
                NSPersistentStoreCoordinator.destroyStore(at: currentURL)
            }
            
            currentURL = destinationURL
        }
        
        try! NSPersistentStoreCoordinator.replaceStore(at: targetURL, withStoreAt: currentURL)
        
        if (currentURL != sourceURL) {
            NSPersistentStoreCoordinator.destroyStore(at: currentURL)
        }
    }
    
    // MARK: - WAL

    func forceWALCheckpointing(storeLocation: URL) {
        let metadata = try! NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: NSSQLiteStoreType, at: storeLocation, options: nil)
        
        let migrationVersionModel = CoreDataMigrationModel.all.first {
            $0.managedObjectModel().isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata)
        }
        
        guard let currentCoreDataStoreMigrationVersionModel = migrationVersionModel else {
            return
        }
        
        let model = currentCoreDataStoreMigrationVersionModel.managedObjectModel()
        let psc = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        let options = [NSSQLitePragmasOption: ["journal_mode": "DELETE"]]
        try! psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeLocation, options: options)
        try! psc.remove(psc.persistentStore(for: storeLocation)!)
    }
}
