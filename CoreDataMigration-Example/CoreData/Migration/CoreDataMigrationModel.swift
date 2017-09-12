//
//  CoreDataMigrationVersion.swift
//  CoreDataMigration-Example
//
//  Created by William Boles on 11/09/2017.
//  Copyright © 2017 William Boles. All rights reserved.
//

import Foundation
import CoreData

enum CoreDataVersion: Int {
    case version1 = 1
    case version2
    case version3
    case version4
    
    // MARK: - Accessors
    
    var name: String {
        if rawValue == 1 {
            return "CoreDataMigration_Example"
        } else {
            return "CoreDataMigration_Example \(rawValue)"
        }
    }
    
    static var all: [CoreDataVersion] {
        var versions = [CoreDataVersion]()
        
        for rawVersionValue in 1...1000 { // A bit of a hack here to avoid manual mapping
            if let version = CoreDataVersion(rawValue: rawVersionValue) {
                versions.append(version)
                continue
            }
            
            break
        }
        
        return versions.reversed()
    }
    
    static var latest: CoreDataVersion {
        return all.first!
    }
}

class CoreDataMigrationModel {
    
    let version: CoreDataVersion
    
    var modelBundle: Bundle {
        return Bundle.main
    }
    
    var modelDirectoryName: String {
        return "CoreDataMigration_Example.momd"
    }
    
    static var all: [CoreDataMigrationModel] {
        var migrationModels = [CoreDataMigrationModel]()
        
        for version in CoreDataVersion.all {
            migrationModels.append(CoreDataMigrationModel(version: version))
        }
        
        return migrationModels
    }
    
    static var current: CoreDataMigrationModel {
        return CoreDataMigrationModel(version: CoreDataVersion.latest)
    }
    
    /**
     Determines the next model version from the current model version.
     
     NB: the next version migration is not always the next actual version. With
     this solution we can skip "bad/corrupted" versions.
     */
    var successor: CoreDataMigrationModel? {
        switch self.version {
        case .version1:
            return CoreDataMigrationModel(version: .version2)
        case .version2:
            return CoreDataMigrationModel(version: .version3)
        case .version3:
            return CoreDataMigrationModel(version: .version4)
        case .version4:
            return nil
        }
    }
    
    // MARK: - Init
    
    init(version: CoreDataVersion) {
        self.version = version
    }
    
    // MARK: - Model
    
    func managedObjectModel() -> NSManagedObjectModel {
        let omoURL = modelBundle.url(forResource: version.name, withExtension: "omo", subdirectory: modelDirectoryName) // optimized model file
        let momURL = modelBundle.url(forResource: version.name, withExtension: "mom", subdirectory: modelDirectoryName)
        
        guard let url = omoURL ?? momURL else {
            fatalError("unable to find model in bundle")
        }
        
        guard let model = NSManagedObjectModel(contentsOf: url) else {
            fatalError("unable to load model in bundle")
        }
        
        return model
    }
    
    // MARK: - Mapping
    
    func mappingModelToSuccessor() -> NSMappingModel? {
        guard let nextVersion = successor else {
            return nil
        }
        
        switch version {
        case .version1, .version2: //manual mapped versions
            guard let mapping = mappingModel(to: nextVersion) else {
                return nil
            }
            
            return mapping
        default:
            return inferredMappingModel(to: nextVersion)
        }
    }
    
    func inferredMappingModel(to nextVersion: CoreDataMigrationModel) -> NSMappingModel {
        do {
            return try NSMappingModel.inferredMappingModel(forSourceModel: managedObjectModel(), destinationModel: nextVersion.managedObjectModel())
        } catch {
            fatalError("unable to generate inferred mapping model")
        }
    }
    
    func mappingModel(to nextVersion: CoreDataMigrationModel) -> NSMappingModel? {
        let sourceModel = managedObjectModel()
        let destinationModel = nextVersion.managedObjectModel()
        guard let mapping = NSMappingModel(from: [modelBundle], forSourceModel: sourceModel, destinationModel: destinationModel) else {
            return nil
        }
        
        return mapping
    }
    
    // MARK: - MigrationSteps
    
    func migrationSteps(to version: CoreDataMigrationModel) -> [CoreDataMigrationStep] {
        guard self.version != version.version else {
            return []
        }
        
        guard let mapping = mappingModelToSuccessor(), let nextVersion = successor else {
            return []
        }
        
        let sourceModel = managedObjectModel()
        let destinationModel = nextVersion.managedObjectModel()
        
        let step = CoreDataMigrationStep(source: sourceModel, destination: destinationModel, mapping: mapping)
        let nextStep = nextVersion.migrationSteps(to: version)
        
        return [step] + nextStep
    }
}

// MARK: - Source

class CoreDataMigrationVersionSourceModel: CoreDataMigrationModel {
    
    // MARK: - Init
    
    init?(storeURL: URL) {
        let metadata = try! NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: NSSQLiteStoreType, at: storeURL, options: nil)
        
        let migrationVersionModel = CoreDataMigrationModel.all.first {
            $0.managedObjectModel().isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata)
        }
        
        guard migrationVersionModel != nil else {
            return nil
        }
        
        super.init(version: migrationVersionModel!.version)
    }
}
