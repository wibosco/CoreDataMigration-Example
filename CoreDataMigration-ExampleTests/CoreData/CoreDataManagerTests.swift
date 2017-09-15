//
//  CoreDataManagerTests.swift
//  CoreDataMigration-ExampleTests
//
//  Created by William Boles on 15/09/2017.
//  Copyright © 2017 William Boles. All rights reserved.
//

import XCTest
import CoreData

@testable import CoreDataMigration_Example

class CoreDataManagerTests: XCTestCase {
    
    class CoreDataMigratorMock: CoreDataMigrator {
        
        var requiresMigrationWasCalled = false
        var migrateStoreWasCalled = false
        
        var requiresMigrationToBeReturned = false
        
        override func requiresMigration(at: URL, currentMigrationModel: CoreDataMigrationModel = CoreDataMigrationModel.current) -> Bool {
            requiresMigrationWasCalled = true
            
            return requiresMigrationToBeReturned
        }
        
        override func migrateStore(at: URL) {
            migrateStoreWasCalled = true
        }
    }
    
    var migrator: CoreDataMigratorMock!
    var manager: CoreDataManager!
    
    // MARK: - Setup

    override func setUp() {
        super.setUp()
        
        migrator = CoreDataMigratorMock()
        manager = CoreDataManager(migrator: migrator)
    }

    override func tearDown() {
        let url = manager.persistentContainer.persistentStoreDescriptions.first!.url!
        NSPersistentStoreCoordinator.destroyStore(at: url)
        
        super.tearDown()
    }

    // MARK: - Setup
    
    func test_setup_loadsStore() {
        let promise = expectation(description: "calls back")
        manager.setup {
            XCTAssertTrue(self.manager.persistentContainer.persistentStoreCoordinator.persistentStores.count > 0)
            
            promise.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                print("Timed out: \(String(describing: error))")
            }
        }
    }

    func test_setup_checksIfMigrationRequired() {
        let promise = expectation(description: "calls back")
        manager.setup {
            XCTAssertTrue(self.migrator.requiresMigrationWasCalled)
            XCTAssertFalse(self.migrator.migrateStoreWasCalled)
            
            promise.fulfill()
        }

        waitForExpectations(timeout: 10) { error in
            if let error = error {
                print("Timed out: \(String(describing: error))")
            }
        }
    }
    
    func test_setup_migrate() {
        migrator.requiresMigrationToBeReturned = true
        
        let promise = expectation(description: "calls back")
        manager.setup {
            XCTAssertTrue(self.migrator.migrateStoreWasCalled)
            
            promise.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                print("Timed out: \(String(describing: error))")
            }
        }
    }
    
}
