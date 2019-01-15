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
    
    override func setUp() {
        super.setUp()
        
        sut = CoreDataMigrator()
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    func tearDownCoreDataStack(context: NSManagedObjectContext) {
        context.destroyStore()
    }
    
    // MARK: - Tests
    
    // MARK: SingleStepMigrations
    
    func test_individualStepMigration_1to2() {
        let sourceURL = FileManager.moveFileFromBundleToTempDirectory(filename: "CoreDataMigration_Example_1.sqlite")
        let toVersion = CoreDataMigrationVersion.version2
        
        sut.migrateStore(at: sourceURL, toVersion: toVersion)
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: sourceURL.path))
        
        let model = NSManagedObjectModel.managedObjectModel(forResource: toVersion.rawValue)
        let context = NSManagedObjectContext(model: model, storeURL: sourceURL)
        let request = NSFetchRequest<NSManagedObject>.init(entityName: "Post")
        let sort = NSSortDescriptor(key: "postID", ascending: false)
        request.sortDescriptors = [sort]
        
        let migratedPosts = try? context.fetch(request)
        
        XCTAssertEqual(migratedPosts?.count, 10)
        
        let firstMigratedPost = migratedPosts?.first
        
        let migratedDate = firstMigratedPost?.value(forKey: "date") as? Date
        let migratedHexColor = firstMigratedPost?.value(forKey: "hexColor") as? String
        let migratedPostID = firstMigratedPost?.value(forKey: "postID") as? String
        let migratedContent = firstMigratedPost?.value(forKey: "content") as? String
        
        XCTAssertEqual(migratedDate?.timeIntervalSince1970, 1547494150.058821)
        XCTAssertEqual(migratedHexColor, "1BB732")
        XCTAssertEqual(migratedPostID, "FFFECB21-6645-4FDD-B8B0-B960D0E61F5A")
        XCTAssertEqual(migratedContent, "Test body")
        
        tearDownCoreDataStack(context: context)
    }
    
    func test_individualStepMigration_2to3() {
        let sourceURL = FileManager.moveFileFromBundleToTempDirectory(filename: "CoreDataMigration_Example_2.sqlite")
        let toVersion = CoreDataMigrationVersion.version3

        sut.migrateStore(at: sourceURL, toVersion: toVersion)

        XCTAssertTrue(FileManager.default.fileExists(atPath: sourceURL.path))

        let model = NSManagedObjectModel.managedObjectModel(forResource: toVersion.rawValue)
        let context = NSManagedObjectContext(model: model, storeURL: sourceURL)

        let postRequest = NSFetchRequest<NSManagedObject>.init(entityName: "Post")
        let postSort = NSSortDescriptor(key: "postID", ascending: false)
        postRequest.sortDescriptors = [postSort]

        let migratedPosts = try? context.fetch(postRequest)

        XCTAssertEqual(migratedPosts?.count, 10)

        let firstMigratedPost = migratedPosts?.first

        let migratedDate = firstMigratedPost?.value(forKey: "date") as? Date
        let migratedPostID = firstMigratedPost?.value(forKey: "postID") as? String
        let migratedTitleContent = firstMigratedPost?.value(forKey: "title") as? NSManagedObject
        let migratedBodyContent = firstMigratedPost?.value(forKey: "body") as? NSManagedObject

        XCTAssertEqual(migratedDate?.timeIntervalSince1970, 1547494150.058821)
        XCTAssertEqual(migratedPostID, "FFFECB21-6645-4FDD-B8B0-B960D0E61F5A")
        XCTAssertNotNil(migratedTitleContent)
        XCTAssertNotNil(migratedBodyContent)

        let migratedTitleContentContent = migratedTitleContent?.value(forKey: "content") as? String
        let migratedTitleContentHexColor = migratedTitleContent?.value(forKey: "hexColor") as? String

        XCTAssertEqual(migratedTitleContentContent, "Test body")
        XCTAssertEqual(migratedTitleContentHexColor, "1BB732")
        
        let migratedBodyContentContent = migratedBodyContent?.value(forKey: "content") as? String
        let migratedBodyContentHexColor = migratedBodyContent?.value(forKey: "hexColor") as? String
        
        XCTAssertEqual(migratedBodyContentContent, "Test body")
        XCTAssertEqual(migratedBodyContentHexColor, "1BB732")

        let contentRequest = NSFetchRequest<NSManagedObject>.init(entityName: "Content")

        let migratedContents = try? context.fetch(contentRequest)

        XCTAssertEqual(migratedContents?.count, 20)
        
        tearDownCoreDataStack(context: context)
    }

    func test_individualStepMigration_3to4() {
        let sourceURL = FileManager.moveFileFromBundleToTempDirectory(filename: "CoreDataMigration_Example_3.sqlite")
        let toVersion = CoreDataMigrationVersion.version4

        sut.migrateStore(at: sourceURL, toVersion: toVersion)

        XCTAssertTrue(FileManager.default.fileExists(atPath: sourceURL.path))

        let model = NSManagedObjectModel.managedObjectModel(forResource: toVersion.rawValue)
        let context = NSManagedObjectContext(model: model, storeURL: sourceURL)

        let postRequest = NSFetchRequest<NSManagedObject>.init(entityName: "Post")
        let postSort = NSSortDescriptor(key: "postID", ascending: false)
        postRequest.sortDescriptors = [postSort]

        let migratedPosts = try? context.fetch(postRequest)

        XCTAssertEqual(migratedPosts?.count, 10)

        let firstMigratedPost = migratedPosts?.first

        let migratedDate = firstMigratedPost?.value(forKey: "date") as? Date
        let migratedPostID = firstMigratedPost?.value(forKey: "postID") as? String
        let migratedSoftDeleted = firstMigratedPost?.value(forKey: "softDeleted") as? Bool
        let migratedTitleContent = firstMigratedPost?.value(forKey: "title") as? NSManagedObject
        let migratedBodyContent = firstMigratedPost?.value(forKey: "body") as? NSManagedObject
        
        XCTAssertEqual(migratedDate?.timeIntervalSince1970, 1547494150.058821)
        XCTAssertEqual(migratedPostID, "FFFECB21-6645-4FDD-B8B0-B960D0E61F5A")
        XCTAssertFalse(migratedSoftDeleted ?? true)
        XCTAssertNotNil(migratedTitleContent)
        XCTAssertNotNil(migratedBodyContent)
        
        let migratedTitleContentContent = migratedTitleContent?.value(forKey: "content") as? String
        let migratedTitleContentHexColor = migratedTitleContent?.value(forKey: "hexColor") as? String
        
        XCTAssertEqual(migratedTitleContentContent, "Test body")
        XCTAssertEqual(migratedTitleContentHexColor, "1BB732")
        
        let migratedBodyContentContent = migratedBodyContent?.value(forKey: "content") as? String
        let migratedBodyContentHexColor = migratedBodyContent?.value(forKey: "hexColor") as? String
        
        XCTAssertEqual(migratedBodyContentContent, "Test body")
        XCTAssertEqual(migratedBodyContentHexColor, "1BB732")
        
        let contentRequest = NSFetchRequest<NSManagedObject>.init(entityName: "Content")
        
        let migratedContents = try? context.fetch(contentRequest)
        
        XCTAssertEqual(migratedContents?.count, 20)
        
        tearDownCoreDataStack(context: context)
    }

    // MARK: MultipleStepMigrations

    func test_multipleStepMigration_fromVersion1toVersion4() {
        let sourceURL = FileManager.moveFileFromBundleToTempDirectory(filename: "CoreDataMigration_Example_1.sqlite")
        let toVersion = CoreDataMigrationVersion.version4

        sut.migrateStore(at: sourceURL, toVersion: toVersion)

        XCTAssertTrue(FileManager.default.fileExists(atPath: sourceURL.path))

        let model = NSManagedObjectModel.managedObjectModel(forResource: toVersion.rawValue)
        let context = NSManagedObjectContext(model: model, storeURL: sourceURL)

        let postRequest = NSFetchRequest<NSManagedObject>.init(entityName: "Post")
        let colorRequest = NSFetchRequest<NSManagedObject>.init(entityName: "Content")

        let migratedPosts = try? context.fetch(postRequest)
        let migratedColors = try? context.fetch(colorRequest)

        XCTAssertEqual(migratedPosts?.count, 10)
        XCTAssertEqual(migratedColors?.count, 20)
        
        tearDownCoreDataStack(context: context)
    }

    // MARK: MigrationRequired

    func test_requiresMigration_fromVersion1ToCurrent_true() {
        let storeURL = FileManager.moveFileFromBundleToTempDirectory(filename: "CoreDataMigration_Example_1.sqlite")

        let requiresMigration = sut.requiresMigration(at: storeURL, toVersion: CoreDataMigrationVersion.latest)

        XCTAssertTrue(requiresMigration)
    }

    func test_requiresMigration_fromVersion3ToVersion3_false() {
        let storeURL = FileManager.moveFileFromBundleToTempDirectory(filename: "CoreDataMigration_Example_3.sqlite")

        let requiresMigration = sut.requiresMigration(at: storeURL, toVersion: .version3)

        XCTAssertFalse(requiresMigration)
    }
}
