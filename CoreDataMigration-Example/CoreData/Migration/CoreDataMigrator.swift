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
    
    func requiresMigration(at storeURL: URL, currentMigrationModel: CoreDataMigrationModel = CoreDataMigrationModel.current) -> Bool {
        guard let metadata = NSPersistentStoreCoordinator.metadata(at: storeURL) else {
            return false
        }

        return !currentMigrationModel.managedObjectModel().isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata)
    }
    
    // MARK: - Migration
    
    func migrateStore(at storeURL: URL) {
        migrateStore(from: storeURL, to: storeURL, targetVersion: CoreDataMigrationModel.current)
    }
    
    func migrateStore(from sourceURL: URL, to targetURL: URL, targetVersion: CoreDataMigrationModel) {
        guard let sourceMigrationModel = CoreDataMigrationSourceModel(storeURL: sourceURL as URL) else {
            fatalError("unknown store version at URL \(sourceURL)")
        }
        
        forceWALCheckpointingForStore(at: sourceURL)
        
        var currentURL = sourceURL
        let migrationSteps = sourceMigrationModel.migrationSteps(to: targetVersion)
        
        for step in migrationSteps {
            let manager = NSMigrationManager(sourceModel: step.source, destinationModel: step.destination)
            let destinationURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent(UUID().uuidString)
            
            do {
                try manager.migrateStore(from: currentURL, sourceType: NSSQLiteStoreType, options: nil, with: step.mapping, toDestinationURL: destinationURL, destinationType: NSSQLiteStoreType, destinationOptions: nil)
            } catch let error {
                fatalError("failed attempting to migrate from \(step.source) to \(step.destination), error: \(error)")
            }
            
            if currentURL != sourceURL {
                //Destroy intermediate step's store
                NSPersistentStoreCoordinator.destroyStore(at: currentURL)
            }
            
            currentURL = destinationURL
        }
        
        NSPersistentStoreCoordinator.replaceStore(at: targetURL, withStoreAt: currentURL)
        
        if (currentURL != sourceURL) {
            NSPersistentStoreCoordinator.destroyStore(at: currentURL)
        }
    }
    
    // MARK: - WAL

    func forceWALCheckpointingForStore(at storeURL: URL) {
        guard let metadata = NSPersistentStoreCoordinator.metadata(at: storeURL), let migrationModel = CoreDataMigrationModel.migrationModelCompatibleWithStoreMetadata(metadata)  else {
            return
        }
        
        do {
            let model = migrationModel.managedObjectModel()
            let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
            
            let options = [NSSQLitePragmasOption: ["journal_mode": "DELETE"]]
            let store = persistentStoreCoordinator.addPersistentStore(at: storeURL, options: options)
            try persistentStoreCoordinator.remove(store)
        } catch let error {
            fatalError("failed to force WAL checkpointing, error: \(error)")
        }
    }
}
