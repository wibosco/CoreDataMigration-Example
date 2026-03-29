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

class StubCoreDataMigrator: CoreDataMigrating {
    enum Event {
        case requiresMigration(URL)
        case migrateStore(URL)
    }
    
    private(set) var events: [Event] = []
    
    var requiresMigrationToBeReturned: Bool!
    
    func requiresMigration(at storeURL: URL) -> Bool {
        events.append(.requiresMigration(storeURL))
        
        return requiresMigrationToBeReturned
    }
    
    func migrateStore(at storeURL: URL) {
        events.append(.migrateStore(storeURL))
    }
}
