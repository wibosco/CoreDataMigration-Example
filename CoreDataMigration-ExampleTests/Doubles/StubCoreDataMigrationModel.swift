//
//  CoreDataMigrationModelSpy.swift
//  CoreDataMigration-ExampleTests
//
//  Created by William Boles on 29/03/2026.
//  Copyright © 2026 William Boles. All rights reserved.
//

import Foundation
import CoreData

@testable import CoreDataMigration_Example

class StubCoreDataMigrationModel: CoreDataMigrationModel {
    enum Event {
        case inferredMappingModel(CoreDataMigrationModel)
        case customMappingModel(CoreDataMigrationModel)
    }
    
    var inferredMappingModel: NSMappingModel!
    var customMappingModelReturnValue: NSMappingModel?
    
    private(set) var events: [Event] = []
    
    override func inferredMappingModel(to nextVersion: CoreDataMigrationModel) -> NSMappingModel {
        events.append(.inferredMappingModel(nextVersion))
        
        return inferredMappingModel
    }
    
    override func customMappingModel(to nextVersion: CoreDataMigrationModel) -> NSMappingModel? {
        events.append(.customMappingModel(nextVersion))
        
        return customMappingModelReturnValue
    }
}
