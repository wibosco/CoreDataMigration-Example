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
    
    var sut: CoreDataMigrator!
    
    // MARK: - Lifecycle
    
    override class func setUp() {
        super.setUp()
        
        FileManager.clearTmpDirectoryContents()
    }
    
    override func setUp() {
        super.setUp()
        
        sut = CoreDataMigrator()
    }
    
    override func tearDown() {
        FileManager.clearTmpDirectoryContents()
        
        sut = nil
        
        super.tearDown()
    }
    
    // MARK: - Tests
    
    // MARK: SingleStepMigrations
    
    func test_individualStepMigration_1to2() {
        let sourceURL = FileManager.moveFileFromBundleToTmpDirectory(fileName: "CoreDataMigration_Example_1.sqlite")
        let targetURL = sourceURL
        let targetVersion = CoreDataMigrationVersion.version2
        
        sut.migrateStore(from: sourceURL, to: targetURL, targetVersion: targetVersion)
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: targetURL.path))
        
        let model = NSManagedObjectModel.managedObjectModel(forResource: targetVersion.rawValue)
        let context = NSManagedObjectContext(model: model, storeURL: targetURL)
        let request = NSFetchRequest<NSManagedObject>.init(entityName: "Post")
        let sort = NSSortDescriptor(key: "postID", ascending: false)
        request.sortDescriptors = [sort]
        
        let migratedPosts = try? context.fetch(request)
        
        XCTAssertEqual(migratedPosts?.count, 1001)
        
        let firstMigratedPost = migratedPosts?.first
        
        let migratedDate = firstMigratedPost?.value(forKey: "date") as? Date
        let migratedHexColor = firstMigratedPost?.value(forKey: "hexColor") as? String
        let migratedPostID = firstMigratedPost?.value(forKey: "postID") as? String
        
        XCTAssertEqual(migratedDate?.timeIntervalSince1970, 1505221438.419883)
        XCTAssertEqual(migratedHexColor, "259EB7")
        XCTAssertEqual(migratedPostID, "FFC75007-7B10-44B5-8B3D-C13FF9E47BAD")
    }
    
    func test_individualStepMigration_2to3() {
        let sourceURL = FileManager.moveFileFromBundleToTmpDirectory(fileName: "CoreDataMigration_Example_2.sqlite")
        let targetURL = sourceURL
        let targetVersion = CoreDataMigrationVersion.version3

        sut.migrateStore(from: sourceURL, to: targetURL, targetVersion: targetVersion)

        XCTAssertTrue(FileManager.default.fileExists(atPath: targetURL.path))
        
        let model = NSManagedObjectModel.managedObjectModel(forResource: targetVersion.rawValue)
        let context = NSManagedObjectContext(model: model, storeURL: targetURL)
        
        let postRequest = NSFetchRequest<NSManagedObject>.init(entityName: "Post")
        let postSort = NSSortDescriptor(key: "postID", ascending: false)
        postRequest.sortDescriptors = [postSort]
        
        let migratedPosts = try? context.fetch(postRequest)
        
        XCTAssertEqual(migratedPosts?.count, 5979)
        
        let firstMigratedPost = migratedPosts?.first
        
        let migratedDate = firstMigratedPost?.value(forKey: "date") as? Date
        let migratedPostID = firstMigratedPost?.value(forKey: "postID") as? String
        let migratedColor = firstMigratedPost?.value(forKey: "color") as? NSManagedObject
        
        XCTAssertEqual(migratedDate?.timeIntervalSince1970, 1505220908.454949)
        XCTAssertEqual(migratedPostID, "FFFF32E3-2643-4FA1-9CB7-9DB4EAE088ED")
        XCTAssertNotNil(migratedColor)
        
        let migratedColorID = migratedColor?.value(forKey: "colorID") as? String
        let migratedHex = migratedColor?.value(forKey: "hex") as? String
        
        XCTAssertNotNil(migratedColorID) //Not a migrated value but rather one that's generated upon migration
        XCTAssertEqual(migratedHex, "511ADB")
        
        let colorRequest = NSFetchRequest<NSManagedObject>.init(entityName: "Color")
        
        let migratedColors = try? context.fetch(colorRequest)
        
        XCTAssertEqual(migratedColors?.count, 5979)
    }

    func test_individualStepMigration_3to4() {
        let sourceURL = FileManager.moveFileFromBundleToTmpDirectory(fileName: "CoreDataMigration_Example_3.sqlite")
        let targetURL = sourceURL
        let targetVersion = CoreDataMigrationVersion.version4

        sut.migrateStore(from: sourceURL, to: targetURL, targetVersion: targetVersion)

        XCTAssertTrue(FileManager.default.fileExists(atPath: targetURL.path))
        
        let model = NSManagedObjectModel.managedObjectModel(forResource: targetVersion.rawValue)
        let context = NSManagedObjectContext(model: model, storeURL: targetURL)
        
        let postRequest = NSFetchRequest<NSManagedObject>.init(entityName: "Post")
        let postSort = NSSortDescriptor(key: "postID", ascending: false)
        postRequest.sortDescriptors = [postSort]
        
        let migratedPosts = try? context.fetch(postRequest)
        
        XCTAssertEqual(migratedPosts?.count, 7995)
        
        let firstMigratedPost = migratedPosts?.first
        
        let migratedDate = firstMigratedPost?.value(forKey: "date") as? Date
        let migratedPostID = firstMigratedPost?.value(forKey: "postID") as? String
        let migratedHide = firstMigratedPost?.value(forKey: "hide") as? Bool
        let migratedColor = firstMigratedPost?.value(forKey: "color") as? NSManagedObject
        
        XCTAssertEqual(migratedDate?.timeIntervalSince1970, 1505220908.454949)
        XCTAssertEqual(migratedPostID, "FFFF32E3-2643-4FA1-9CB7-9DB4EAE088ED")
        XCTAssertFalse(migratedHide ?? true)
        XCTAssertNotNil(migratedColor)
        
        let colorRequest = NSFetchRequest<NSManagedObject>.init(entityName: "Color")
        let colorSort = NSSortDescriptor(key: "colorID", ascending: false)
        colorRequest.sortDescriptors = [colorSort]
        
        let migratedColors = try? context.fetch(colorRequest)
        
        XCTAssertEqual(migratedColors?.count, 7995)
        
        let firstMigratedColor = migratedColors?.first
        
        let migratedColorID = firstMigratedColor?.value(forKey: "colorID") as? String
        let migratedHex = firstMigratedColor?.value(forKey: "hex") as? String
        
        XCTAssertEqual(migratedColorID, "FFF20DBB-6C19-4E74-AD20-1DA56255BB54")
        XCTAssertEqual(migratedHex, "29FCE8")
    }

    // MARK: MultipleStepMigrations

    func test_multipleStepMigration_fromVersion1toVersion4() {
        let sourceURL = FileManager.moveFileFromBundleToTmpDirectory(fileName: "CoreDataMigration_Example_1.sqlite")
        let targetURL = sourceURL
        let targetVersion = CoreDataMigrationVersion.version4

        sut.migrateStore(from: sourceURL, to: targetURL, targetVersion: targetVersion)

        XCTAssertTrue(FileManager.default.fileExists(atPath: targetURL.path))
        
        let model = NSManagedObjectModel.managedObjectModel(forResource: targetVersion.rawValue)
        let context = NSManagedObjectContext(model: model, storeURL: targetURL)
        
        let postRequest = NSFetchRequest<NSManagedObject>.init(entityName: "Post")
        let colorRequest = NSFetchRequest<NSManagedObject>.init(entityName: "Color")
        
        let migratedPosts = try? context.fetch(postRequest)
        let migratedColors = try? context.fetch(colorRequest)
        
        XCTAssertEqual(migratedPosts?.count, 1001)
        XCTAssertEqual(migratedColors?.count, 1001)
    }

    // MARK: MigrationRequired

    func test_requiresMigration_fromVersion1ToCurrent_true() {
        let storeURL = FileManager.moveFileFromBundleToTmpDirectory(fileName: "CoreDataMigration_Example_1.sqlite")

        let requiresMigration = sut.requiresMigration(at: storeURL)

        XCTAssertTrue(requiresMigration)
    }

    func test_requiresMigration_fromVersion3ToVersion3_false() {
        let storeURL = FileManager.moveFileFromBundleToTmpDirectory(fileName: "CoreDataMigration_Example_3.sqlite")

        let requiresMigration = sut.requiresMigration(at: storeURL, toVersion: .version3)

        XCTAssertFalse(requiresMigration)
    }

    // MARK: CheckPointing

    func test_forceWALTransactions_success() {
        let storeURL = FileManager.moveFileFromBundleToTmpDirectory(fileName: "CoreDataMigration_Example_WAL.sqlite")
        let walLocation = FileManager.moveFileFromBundleToTmpDirectory(fileName: "CoreDataMigration_Example_WAL.sqlite-wal")

        let sizeBeforeCheckPointing = try! FileManager.default.attributesOfItem(atPath: storeURL.path)[FileAttributeKey.size] as! NSNumber

        sut.forceWALCheckpointingForStore(at: storeURL)

        let sizeAfterCheckPointing = try! FileManager.default.attributesOfItem(atPath: storeURL.path)[FileAttributeKey.size] as! NSNumber

        XCTAssertFalse(FileManager.default.fileExists(atPath: walLocation.path))
        XCTAssertTrue(sizeAfterCheckPointing.doubleValue > sizeBeforeCheckPointing.doubleValue)
    }
}
