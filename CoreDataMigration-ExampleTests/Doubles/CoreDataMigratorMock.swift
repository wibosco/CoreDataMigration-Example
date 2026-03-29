//
//  CoreDataMigratorMock.swift
//  CoreDataMigration-ExampleTests
//
//  Created by William Boles on 29/03/2026.
//  Copyright © 2026 William Boles. All rights reserved.
//

import Foundation
import CoreData

@testable import CoreDataMigration_Example

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
