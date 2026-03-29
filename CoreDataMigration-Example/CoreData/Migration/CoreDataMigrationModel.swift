//
//  CoreDataMigrationVersion.swift
//  CoreDataMigration-Example
//
//  Created by William Boles on 11/09/2017.
//  Copyright © 2017 William Boles. All rights reserved.
//

import Foundation
import CoreData

class CoreDataMigrationModel {
    private let version: CoreDataVersion
    
    static var all: [CoreDataMigrationModel] {
        return CoreDataVersion.allCases.map { CoreDataMigrationModel(version: $0) }
    }
    
    static var current: CoreDataMigrationModel {
        return CoreDataMigrationModel(version: CoreDataVersion.latest)
    }
    
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
        let omoURL = Bundle.main.url(forResource: version.rawValue,
                                     withExtension: "omo",
                                     subdirectory: "CoreDataMigration_Example.momd") // optimized model file
        
        let momURL = Bundle.main.url(forResource: version.rawValue,
                                     withExtension: "mom",
                                     subdirectory: "CoreDataMigration_Example.momd")
        
        guard let url = omoURL ?? momURL else {
            fatalError("Unable to find model in bundle")
        }
        
        guard let model = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Unable to load model in bundle")
        }
        
        return model
    }
    
    // MARK: - Mapping
    
    func mappingModelToSuccessor() -> NSMappingModel? {
        guard let nextVersion = successor else {
            return nil
        }

        return customMappingModel(to: nextVersion) ?? inferredMappingModel(to: nextVersion)
    }
    
    func customMappingModel(to nextVersion: CoreDataMigrationModel) -> NSMappingModel? {
        let sourceModel = managedObjectModel()
        let destinationModel = nextVersion.managedObjectModel()

        return NSMappingModel(from: [Bundle.main],
                              forSourceModel: sourceModel,
                              destinationModel: destinationModel)
    }
    
    func inferredMappingModel(to nextVersion: CoreDataMigrationModel) -> NSMappingModel {
        do {
            let sourceModel = managedObjectModel()
            let destinationModel = nextVersion.managedObjectModel()
            
            return try NSMappingModel.inferredMappingModel(forSourceModel: sourceModel,
                                                           destinationModel: destinationModel)
        } catch {
            fatalError("Unable to generate inferred mapping model")
        }
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
        
        let step = CoreDataMigrationStep(source: sourceModel,
                                         destination: destinationModel,
                                         mapping: mapping)
        let nextStep = nextVersion.migrationSteps(to: version)
        
        return [step] + nextStep
    }
    
    // MARK: - Metadata
    
    static func migrationModelCompatibleWithStoreMetadata(_ metadata: [String : Any]) -> CoreDataMigrationModel? {
        let compatibleMigrationModel = CoreDataMigrationModel.all.first {
            $0.managedObjectModel().isConfiguration(withName: nil,
                                                    compatibleWithStoreMetadata: metadata)
        }
        
        return compatibleMigrationModel
    }
}
