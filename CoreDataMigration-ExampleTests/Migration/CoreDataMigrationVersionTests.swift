//
//  CoreDataMigrationVersionTests.swift
//  CoreDataMigration-ExampleTests
//
//  Created by William Boles on 12/09/2017.
//  Copyright © 2017 William Boles. All rights reserved.
//

import XCTest
import CoreData

@testable import CoreDataMigration_Example

class CoreDataMigrationVersionTests: XCTestCase {
    
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
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: - Source
    
    func test_sourceInit_validStoreURL() {
        let storeURL = Bundle(for: CoreDataMigrationVersionTests.self).resourceURL!.appendingPathComponent("CoreDataMigration_Example_2.sqlite")
        let coreDataMigrationVersion = CoreDataMigrationVersionSourceModel(storeURL: storeURL)
        
        XCTAssertNotNil(coreDataMigrationVersion)
        XCTAssertEqual(coreDataMigrationVersion!.version.name, "CoreDataMigration_Example 2")
    }
    
    // MARK: - Steps
    
    func test_migrationSteps_singleStep() {
        let version2 = CoreDataMigrationModel(version: .version2)
        let version3 = CoreDataMigrationModel(version: .version3)
        
        let steps = version2.migrationSteps(to: version3)
        
        let step2to3 = steps.first
        
        let version2Model = version2.managedObjectModel()
        let version3Model = version3.managedObjectModel()
        
        XCTAssertEqual(steps.count, 1)
        XCTAssertEqual(step2to3?.source, version2Model)
        XCTAssertEqual(step2to3?.destination, version3Model)
    }
    
    func test_migrationSteps_multipleSteps() {
        let version1 = CoreDataMigrationModel(version: .version1)
        let version3 = CoreDataMigrationModel(version: .version3)
        let version4 = CoreDataMigrationModel(version: .version4)
        
        let steps = version1.migrationSteps(to: version4)
        
        let step3to4 = steps.last
        
        let version3Model = version3.managedObjectModel()
        let version4Model = version4.managedObjectModel()
        
        XCTAssertEqual(steps.count, 3)
        XCTAssertEqual(step3to4?.source, version3Model)
        XCTAssertEqual(step3to4?.destination, version4Model)
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
}
