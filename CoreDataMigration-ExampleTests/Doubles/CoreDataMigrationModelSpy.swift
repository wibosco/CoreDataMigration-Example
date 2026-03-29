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

class CoreDataMigrationModelSpy: CoreDataMigrationModel {
    
    var inferredMappingModelWasCalled = false
    var customMappingModelWasCalled = false
    
    override func inferredMappingModel(to nextVersion: CoreDataMigrationModel) -> NSMappingModel {
        inferredMappingModelWasCalled = true
        
        return NSMappingModel()
    }
    
    override func customMappingModel(to nextVersion: CoreDataMigrationModel) -> NSMappingModel? {
        customMappingModelWasCalled = true
        
        return NSMappingModel()
    }
}
