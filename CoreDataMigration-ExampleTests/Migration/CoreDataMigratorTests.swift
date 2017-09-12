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
    
    func clearTmpDirectoryContents() {
        let tmpDirectoryContents = try! FileManager.default.contentsOfDirectory(atPath: NSTemporaryDirectory())
        tmpDirectoryContents.forEach {
            let fileURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent($0)
            try! FileManager.default.removeItem(atPath: fileURL.path)
        }
    }
    
    func moveFileFromBundleToTmpDirectory(fileName: String) -> URL {
        let destinationURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent(fileName)
        let bundleURL = Bundle(for: CoreDataMigratorTests.self).resourceURL!.appendingPathComponent(fileName)
        try! FileManager.default.copyItem(at: bundleURL, to: destinationURL)
        
        return destinationURL
    }
    
    // MARK: - Properties
    
    var migrator: CoreDataMigrator!
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        clearTmpDirectoryContents()
        migrator = CoreDataMigrator()
    }
    
    override func tearDown() {
        clearTmpDirectoryContents()
        super.tearDown()
    }
    
    // MARK: - SingleStepMigrations
    
    func test_individualStepMigration_1to2() {
        let sourceURL = self.moveFileFromBundleToTmpDirectory(fileName: "CoreDataMigration_Example_1.sqlite")
        let targetURL = sourceURL
        
        let modifiedDateBeforeMigration = try! FileManager.default.attributesOfItem(atPath: sourceURL.path)[FileAttributeKey.modificationDate] as! Date
        
        migrator.migrateStore(from: sourceURL, to: targetURL, targetVersion: CoreDataMigrationModel(version: .version2))
        
        let modifiedDateAfterMigration = try! FileManager.default.attributesOfItem(atPath: targetURL.path)[FileAttributeKey.modificationDate] as! Date
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: targetURL.path))
        XCTAssertTrue(modifiedDateAfterMigration.timeIntervalSince(modifiedDateBeforeMigration) > 0)
    }
    
    func test_individualStepMigration_2to3() {
        let sourceURL = self.moveFileFromBundleToTmpDirectory(fileName: "CoreDataMigration_Example_2.sqlite")
        let targetURL = sourceURL
        
        let modifiedDateBeforeMigration = try! FileManager.default.attributesOfItem(atPath: sourceURL.path)[FileAttributeKey.modificationDate] as! Date
        
        migrator.migrateStore(from: sourceURL, to: targetURL, targetVersion: CoreDataMigrationModel(version: .version3))
        
        let modifiedDateAfterMigration = try! FileManager.default.attributesOfItem(atPath: targetURL.path)[FileAttributeKey.modificationDate] as! Date
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: targetURL.path))
        XCTAssertTrue(modifiedDateAfterMigration.timeIntervalSince(modifiedDateBeforeMigration) > 0)
    }
    
    func test_individualStepMigration_3to4() {
        let sourceURL = self.moveFileFromBundleToTmpDirectory(fileName: "CoreDataMigration_Example_3.sqlite")
        let targetURL = sourceURL
        
        let modifiedDateBeforeMigration = try! FileManager.default.attributesOfItem(atPath: sourceURL.path)[FileAttributeKey.modificationDate] as! Date
        
        migrator.migrateStore(from: sourceURL, to: targetURL, targetVersion: CoreDataMigrationModel(version: .version4))
        
        let modifiedDateAfterMigration = try! FileManager.default.attributesOfItem(atPath: targetURL.path)[FileAttributeKey.modificationDate] as! Date
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: targetURL.path))
        XCTAssertTrue(modifiedDateAfterMigration.timeIntervalSince(modifiedDateBeforeMigration) > 0)
    }
    
    // MARK: - MultipleStepMigrations
    
    func test_multipleStepMigration_1to4() {
        let sourceURL = self.moveFileFromBundleToTmpDirectory(fileName: "CoreDataMigration_Example_1.sqlite")
        let targetURL = sourceURL
        
        let modifiedDateBeforeMigration = try! FileManager.default.attributesOfItem(atPath: sourceURL.path)[FileAttributeKey.modificationDate] as! Date
        
        migrator.migrateStore(from: sourceURL, to: targetURL, targetVersion: CoreDataMigrationModel(version: .version4))
        
        let modifiedDateAfterMigration = try! FileManager.default.attributesOfItem(atPath: targetURL.path)[FileAttributeKey.modificationDate] as! Date
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: targetURL.path))
        XCTAssertTrue(modifiedDateAfterMigration.timeIntervalSince(modifiedDateBeforeMigration) > 0)
    }
    
    // MARK: - MigrationRequired
    
    func test_requiresMigration_true() {
        let storeLocation = self.moveFileFromBundleToTmpDirectory(fileName: "CoreDataMigration_Example_1.sqlite")
        
        let requiresMigration = migrator.requiresMigration(storeLocation: storeLocation)
        
        XCTAssertTrue(requiresMigration)
    }
    
    func test_requiresMigration_false() {
        let storeLocation = self.moveFileFromBundleToTmpDirectory(fileName: "CoreDataMigration_Example_3.sqlite")
        let migrationModel = CoreDataMigrationModel(version: .version3)
        
        let requiresMigration = migrator.requiresMigration(storeLocation: storeLocation, currentMigrationModel: migrationModel)
        
        XCTAssertFalse(requiresMigration)
    }
    
    // MARK: - CheckPointing
    
    func test_forceWALTransactions_success() {
        let storeLocation = self.moveFileFromBundleToTmpDirectory(fileName: "CoreDataMigration_Example_WAL.sqlite")
        let walLocation = self.moveFileFromBundleToTmpDirectory(fileName: "CoreDataMigration_Example_WAL.sqlite-wal")
        
        let sizeBeforeCheckPointing = try! FileManager.default.attributesOfItem(atPath: storeLocation.path)[FileAttributeKey.size] as! NSNumber
        
        migrator.forceWALCheckpointing(storeLocation: storeLocation)
        
        let sizeAfterCheckPointing = try! FileManager.default.attributesOfItem(atPath: storeLocation.path)[FileAttributeKey.size] as! NSNumber
        
        XCTAssertFalse(FileManager.default.fileExists(atPath: walLocation.path))
        XCTAssertTrue(sizeAfterCheckPointing.doubleValue > sizeBeforeCheckPointing.doubleValue)
    }
}
