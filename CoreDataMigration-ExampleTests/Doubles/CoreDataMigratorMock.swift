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
    enum Event {
        case requiresMigration(URL, CoreDataMigrationModel)
        case migrateStore(URL)
    }
    
    private(set) var events: [Event] = []
    
    var requiresMigrationToBeReturned: Bool!
    
    override func requiresMigration(at: URL, currentMigrationModel: CoreDataMigrationModel = CoreDataMigrationModel.current) -> Bool {
        events.append(.requiresMigration(at, currentMigrationModel))
        
        return requiresMigrationToBeReturned
    }
    
    override func migrateStore(at: URL) {
        events.append(.migrateStore(at))
    }
}
