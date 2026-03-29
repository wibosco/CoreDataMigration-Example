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
    
    // MARK: - Tests
    
    // MARK: - Current
    
    func test_givenLatestVersion_whenAccessingCurrent_thenReturnsLatestVersion() {
        let currentModel = CoreDataMigrationModel.current
        let expectedModel = CoreDataMigrationModel(version: .version4)
        
        XCTAssertEqual(currentModel.managedObjectModel(), expectedModel.managedObjectModel())
    }
    
    // MARK: - All
    
    func test_givenAllVersionsExist_whenAccessingAll_thenReturnsModelForEveryVersion() {
        let allModels = CoreDataMigrationModel.all
        
        XCTAssertEqual(allModels.count, CoreDataVersion.allCases.count)
    }
    
    func test_givenAllVersionsExist_whenAccessingAll_thenModelsAreInVersionOrder() {
        let allModels = CoreDataMigrationModel.all
        let expectedModels = CoreDataVersion.allCases.map { CoreDataMigrationModel(version: $0).managedObjectModel() }
        
        XCTAssertEqual(allModels.map { $0.managedObjectModel() }, expectedModels)
    }
    
    // MARK: - Successor
    
    func test_givenVersion1_whenAccessingSuccessor_thenReturnsVersion2() {
        let sut = CoreDataMigrationModel(version: .version1)
        let expected = CoreDataMigrationModel(version: .version2)
        
        XCTAssertEqual(sut.successor?.managedObjectModel(), expected.managedObjectModel())
    }
    
    func test_givenVersion2_whenAccessingSuccessor_thenReturnsVersion3() {
        let sut = CoreDataMigrationModel(version: .version2)
        let expected = CoreDataMigrationModel(version: .version3)
        
        XCTAssertEqual(sut.successor?.managedObjectModel(), expected.managedObjectModel())
    }
    
    func test_givenVersion3_whenAccessingSuccessor_thenReturnsVersion4() {
        let sut = CoreDataMigrationModel(version: .version3)
        let expected = CoreDataMigrationModel(version: .version4)
        
        XCTAssertEqual(sut.successor?.managedObjectModel(), expected.managedObjectModel())
    }
    
    func test_givenVersion4_whenAccessingSuccessor_thenReturnsNil() {
        let sut = CoreDataMigrationModel(version: .version4)
        
        XCTAssertNil(sut.successor)
    }
    
    // MARK: - ManagedObjectModel
    
    func test_givenValidVersion_whenLoadingManagedObjectModel_thenReturnsModel() {
        let sut = CoreDataMigrationModel(version: .version3)
        
        let managedObjectModel = sut.managedObjectModel()
        
        XCTAssertNotNil(managedObjectModel)
    }
    
    func test_givenTwoInstancesOfSameVersion_whenLoadingManagedObjectModel_thenModelsAreEqual() {
        let first = CoreDataMigrationModel(version: .version2)
        let second = CoreDataMigrationModel(version: .version2)
        
        XCTAssertEqual(first.managedObjectModel(), second.managedObjectModel())
    }
    
    func test_givenDifferentVersions_whenLoadingManagedObjectModel_thenModelsAreNotEqual() {
        let version1 = CoreDataMigrationModel(version: .version1)
        let version2 = CoreDataMigrationModel(version: .version2)
        
        XCTAssertNotEqual(version1.managedObjectModel(), version2.managedObjectModel())
    }
    
    // MARK: - MappingModelToSuccessor
    
    func test_givenVersion1_whenRequestingMappingToSuccessor_thenUsesCustomMapping() {
        let sut = StubCoreDataMigrationModel(version: .version1)
        sut.customMappingModelReturnValue = NSMappingModel()
        
        let mappingModel = sut.mappingModelToSuccessor()
        
        XCTAssertNotNil(mappingModel)
        XCTAssertEqual(sut.events.count, 1)
        
        if case .customMappingModel = sut.events.first {} else {
            XCTFail("Expected customMappingModel event")
        }
    }
    
    func test_givenVersion2_whenRequestingMappingToSuccessor_thenUsesCustomMapping() {
        let sut = StubCoreDataMigrationModel(version: .version2)
        sut.customMappingModelReturnValue = NSMappingModel()
        
        let mappingModel = sut.mappingModelToSuccessor()
        
        XCTAssertNotNil(mappingModel)
        XCTAssertEqual(sut.events.count, 1)
        
        if case .customMappingModel = sut.events.first {} else {
            XCTFail("Expected customMappingModel event")
        }
    }
    
    func test_givenVersion3_whenRequestingMappingToSuccessor_thenUsesInferredMapping() {
        let sut = StubCoreDataMigrationModel(version: .version3)
        sut.customMappingModelReturnValue = nil
        sut.inferredMappingModel = NSMappingModel()
        
        let mappingModel = sut.mappingModelToSuccessor()
        
        XCTAssertNotNil(mappingModel)
        XCTAssertEqual(sut.events.count, 2)
        
        if case .customMappingModel = sut.events.first {} else {
            XCTFail("Expected customMappingModel event first")
        }
        
        if case .inferredMappingModel = sut.events.last {} else {
            XCTFail("Expected inferredMappingModel event second")
        }
    }
    
    func test_givenVersion4_whenRequestingMappingToSuccessor_thenReturnsNil() {
        let sut = CoreDataMigrationModel(version: .version4)
        
        let mappingModel = sut.mappingModelToSuccessor()
        
        XCTAssertNil(mappingModel)
    }
    
    // MARK: - MigrationSteps
    
    func test_givenAdjacentVersions_whenCalculatingMigrationSteps_thenReturnsSingleStep() {
        let source = CoreDataMigrationModel(version: .version2)
        let destination = CoreDataMigrationModel(version: .version3)
        
        let steps = source.migrationSteps(to: destination)
        
        XCTAssertEqual(steps.count, 1)
        XCTAssertEqual(steps.first?.source, source.managedObjectModel())
        XCTAssertEqual(steps.first?.destination, destination.managedObjectModel())
    }
    
    func test_givenNonAdjacentVersions_whenCalculatingMigrationSteps_thenReturnsMultipleSteps() {
        let source = CoreDataMigrationModel(version: .version1)
        let destination = CoreDataMigrationModel(version: .version3)
        
        let steps = source.migrationSteps(to: destination)
        
        XCTAssertEqual(steps.count, 2)
        XCTAssertEqual(steps.first?.source, source.managedObjectModel())
        XCTAssertEqual(steps.last?.destination, destination.managedObjectModel())
    }
    
    func test_givenVersion1_whenMigratingToCurrent_thenReturnsStepForEachVersionGap() {
        let source = CoreDataMigrationModel(version: .version1)
        let destination = CoreDataMigrationModel.current
        
        let steps = source.migrationSteps(to: destination)
        
        XCTAssertEqual(steps.count, CoreDataVersion.allCases.count - 1)
    }
    
    func test_givenSameVersion_whenCalculatingMigrationSteps_thenReturnsEmptyArray() {
        let sut = CoreDataMigrationModel(version: .version3)
        
        let steps = sut.migrationSteps(to: sut)
        
        XCTAssertTrue(steps.isEmpty)
    }
    
    func test_givenLatestVersion_whenCalculatingMigrationSteps_thenReturnsEmptyArray() {
        let sut = CoreDataMigrationModel(version: .version4)
        let destination = CoreDataMigrationModel(version: .version4)
        
        let steps = sut.migrationSteps(to: destination)
        
        XCTAssertTrue(steps.isEmpty)
    }
    
    func test_givenMultipleSteps_whenCalculatingMigrationSteps_thenStepsAreChainedInOrder() {
        let source = CoreDataMigrationModel(version: .version1)
        let destination = CoreDataMigrationModel(version: .version4)
        
        let steps = source.migrationSteps(to: destination)
        
        XCTAssertEqual(steps.count, 3)
        
        // Each step's destination should match the next step's source
        for i in 0..<(steps.count - 1) {
            XCTAssertEqual(steps[i].destination, steps[i + 1].source)
        }
    }
}
