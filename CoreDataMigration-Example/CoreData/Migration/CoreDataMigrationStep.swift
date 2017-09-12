//
//  CoreDataMigrationStep.swift
//  CoreDataMigration-Example
//
//  Created by William Boles on 11/09/2017.
//  Copyright © 2017 William Boles. All rights reserved.
//

import CoreData

struct CoreDataMigrationStep {
    
    let source: NSManagedObjectModel
    let destination: NSManagedObjectModel
    let mapping: NSMappingModel
}
