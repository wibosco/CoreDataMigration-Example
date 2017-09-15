//
//  CoreDataMigrationModelTests.swift
//  CoreDataMigration-ExampleTests
//
//  Created by William Boles on 12/09/2017.
//  Copyright © 2017 William Boles. All rights reserved.
//

import XCTest
import CoreData

@testable import CoreDataMigration_Example

class CoreDataMigrationModelTests: XCTestCase {
    
    // MARK: - CustomClasses
    
    class CoreDataMigrationModelSpy: CoreDataMigrationModel {
        
        var inferredMappingModelWasCalled = false
        var manualMappingModelWasCalled = false
        
        override func inferredMappingModel(to nextVersion: CoreDataMigrationModel) -> NSMappingModel {
            inferredMappingModelWasCalled = true
            
            return NSMappingModel()
        }
        
        override func manualMappingModel(to nextVersion: CoreDataMigrationModel) -> NSMappingModel? {
            manualMappingModelWasCalled = true
            
            return NSMappingModel()
        }
    }
    
    // MARK: - Source
    
    func test_sourceInit_validStoreURL() {
        let storeURL = Bundle(for: CoreDataMigrationModelTests.self).resourceURL!.appendingPathComponent("CoreDataMigration_Example_2.sqlite")
        let coreDataMigrationModel = CoreDataMigrationSourceModel(storeURL: storeURL)
        
        XCTAssertNotNil(coreDataMigrationModel)
        XCTAssertEqual(coreDataMigrationModel!.version.name, "CoreDataMigration_Example 2")
    }
    
    // MARK: - Steps
    
    func test_migrationSteps_singleStep() {
        let version2 = CoreDataMigrationModel(version: .version2)
        let version3 = CoreDataMigrationModel(version: .version3)
        
        let steps = version2.migrationSteps(to: version3)
        
        let firstStep = steps.first
        
        let sourceModel = version2.managedObjectModel()
        let destinationModel = version3.managedObjectModel()
        
        XCTAssertEqual(steps.count, 1)
        XCTAssertEqual(firstStep?.source, sourceModel)
        XCTAssertEqual(firstStep?.destination, destinationModel)
    }
    
    func test_migrationSteps_multipleSteps() {
        let version1 = CoreDataMigrationModel(version: .version1)
        let version2 = CoreDataMigrationModel(version: .version2)
        let version3 = CoreDataMigrationModel(version: .version3)
        
        let steps = version1.migrationSteps(to: version3)
        
        let lastStep = steps.last
        
        let sourceModel = version2.managedObjectModel()
        let destinationModel = version3.managedObjectModel()
        
        XCTAssertEqual(steps.count, 2)
        XCTAssertEqual(lastStep?.source, sourceModel)
        XCTAssertEqual(lastStep?.destination, destinationModel)
    }
    
    func test_migrationSteps_toCurrent() {
        let version1 = CoreDataMigrationModel(version: .version1)
        let currentVersion = CoreDataMigrationModel.current
        
        let steps = version1.migrationSteps(to: currentVersion)
        
        XCTAssertEqual(steps.count, (CoreDataVersion.all.count - 1))
    }
    
    func test_migrationSteps_cannotMigrateToSelf() {
        let version3 = CoreDataMigrationModel(version: .version3)
        
        let steps = version3.migrationSteps(to: version3)
        
        XCTAssertEqual(steps.count, 0)
    }
    
    // MARK: - Model
    
    func test_retrieveModel_findAndLoad() {
         let version3 = CoreDataMigrationModel(version: .version3)
        
        let managedObjectModel = version3.managedObjectModel()
        
        XCTAssertNotNil(managedObjectModel)
    }
    
    // MARK: - Successor
    
    func test_fromVersion1_manualMapping() {
        let version = CoreDataMigrationModelSpy(version: .version1)
        
        let mappingModel = version.mappingModelToSuccessor()
        
        XCTAssertNotNil(mappingModel)
        XCTAssertTrue(version.manualMappingModelWasCalled)
    }
    
    func test_fromVersion2_manualMapping() {
        let version = CoreDataMigrationModelSpy(version: .version2)
        
        let mappingModel = version.mappingModelToSuccessor()
        
        XCTAssertNotNil(mappingModel)
        XCTAssertTrue(version.manualMappingModelWasCalled)
    }
    
    func test_fromVersion3_inferredMapping() {
        let version = CoreDataMigrationModelSpy(version: .version3)
        
        let mappingModel = version.mappingModelToSuccessor()
        
        XCTAssertNotNil(mappingModel)
        XCTAssertTrue(version.inferredMappingModelWasCalled)
    }
    
    // MARK: - Current
    
    func test_current() {
        let lastVersion = CoreDataVersion.all.first!
        
        let expectedModel = CoreDataMigrationModel(version: lastVersion)
        let currentModel = CoreDataMigrationModel.current
        
        XCTAssertEqual(expectedModel.version, currentModel.version)
    }
}
