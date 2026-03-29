//
//  CoreDataMigratorTests.swift
//  CoreDataMigration-ExampleTests
//
//  Created by William Boles on 12/09/2017.
//  Copyright © 2017 William Boles. All rights reserved.
//

import XCTest
import CoreData

@testable import CoreDataMigration_Example

class CoreDataMigratorTests: XCTestCase {
    
    static func clearTmpDirectoryContents() {
        let tmpDirectoryContents = try! FileManager.default.contentsOfDirectory(atPath: NSTemporaryDirectory())
        tmpDirectoryContents.forEach {
            let fileURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent($0)
            try! FileManager.default.removeItem(atPath: fileURL.path)
        }
    }
    
    static func moveFileFromBundleToTmpDirectory(fileName: String) -> URL {
        let destinationURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent(fileName)
        let bundleURL = Bundle(for: CoreDataMigratorTests.self).resourceURL!.appendingPathComponent(fileName)
        try! FileManager.default.copyItem(at: bundleURL, to: destinationURL)
        
        return destinationURL
    }
    
    // MARK: - Properties
    
    var sut: CoreDataMigrator!
    
    // MARK: - Setup
    
    override class func setUp() {
        super.setUp()
        clearTmpDirectoryContents()
    }
    
    override func setUp() {
        super.setUp()
        sut = CoreDataMigrator()
    }
    
    override func tearDown() {
        CoreDataMigratorTests.clearTmpDirectoryContents()
        super.tearDown()
    }
    
    // MARK: - MigrateStore
    
    func test_givenVersion1Store_whenMigratingStore_thenStoreIsUpdated() {
        let storeURL = CoreDataMigratorTests.moveFileFromBundleToTmpDirectory(fileName: "CoreDataMigration_Example_1.sqlite")
        
        let modifiedDateBeforeMigration = try! FileManager.default.attributesOfItem(atPath: storeURL.path)[FileAttributeKey.modificationDate] as! Date
        
        sut.migrateStore(at: storeURL)
        
        let modifiedDateAfterMigration = try! FileManager.default.attributesOfItem(atPath: storeURL.path)[FileAttributeKey.modificationDate] as! Date
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: storeURL.path))
        XCTAssertTrue(modifiedDateAfterMigration.timeIntervalSince(modifiedDateBeforeMigration) > 0)
    }
    
    func test_givenVersion2Store_whenMigratingStore_thenStoreIsUpdated() {
        let storeURL = CoreDataMigratorTests.moveFileFromBundleToTmpDirectory(fileName: "CoreDataMigration_Example_2.sqlite")
        
        let modifiedDateBeforeMigration = try! FileManager.default.attributesOfItem(atPath: storeURL.path)[FileAttributeKey.modificationDate] as! Date
        
        sut.migrateStore(at: storeURL)
        
        let modifiedDateAfterMigration = try! FileManager.default.attributesOfItem(atPath: storeURL.path)[FileAttributeKey.modificationDate] as! Date
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: storeURL.path))
        XCTAssertTrue(modifiedDateAfterMigration.timeIntervalSince(modifiedDateBeforeMigration) > 0)
    }
    
    func test_givenVersion3Store_whenMigratingStore_thenStoreIsUpdated() {
        let storeURL = CoreDataMigratorTests.moveFileFromBundleToTmpDirectory(fileName: "CoreDataMigration_Example_3.sqlite")
        
        let modifiedDateBeforeMigration = try! FileManager.default.attributesOfItem(atPath: storeURL.path)[FileAttributeKey.modificationDate] as! Date
        
        sut.migrateStore(at: storeURL)
        
        let modifiedDateAfterMigration = try! FileManager.default.attributesOfItem(atPath: storeURL.path)[FileAttributeKey.modificationDate] as! Date
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: storeURL.path))
        XCTAssertTrue(modifiedDateAfterMigration.timeIntervalSince(modifiedDateBeforeMigration) > 0)
    }
    
    // MARK: - RequiresMigration
    
    func test_givenOldVersionStore_whenCheckingRequiresMigration_thenReturnsTrue() {
        let storeURL = CoreDataMigratorTests.moveFileFromBundleToTmpDirectory(fileName: "CoreDataMigration_Example_1.sqlite")
        
        let requiresMigration = sut.requiresMigration(at: storeURL)
        
        XCTAssertTrue(requiresMigration)
    }
    
    func test_givenCurrentVersionStore_whenCheckingRequiresMigration_thenReturnsFalse() {
        let storeURL = CoreDataMigratorTests.moveFileFromBundleToTmpDirectory(fileName: "CoreDataMigration_Example_3.sqlite")
        
        sut.migrateStore(at: storeURL)
        
        let requiresMigration = sut.requiresMigration(at: storeURL)
        
        XCTAssertFalse(requiresMigration)
    }
}
