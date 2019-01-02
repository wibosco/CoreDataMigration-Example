//
//  NSManagedObjectModel+Compatible.swift
//  CoreDataMigration-Example
//
//  Created by William Boles on 02/01/2019.
//  Copyright © 2019 William Boles. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectModel {
    
    // MARK: - Compatible
    
    static func compatibleModelForStoreMetadata(_ metadata: [String : Any]) -> NSManagedObjectModel? {
        guard let compatibleModelVersion = CoreDataMigrationVersion.compatibleVersionForStoreMetadata(metadata) else {
            return nil
        }
        
        return NSManagedObjectModel.managedObjectModel(forResource: compatibleModelVersion.rawValue)
    }
}
