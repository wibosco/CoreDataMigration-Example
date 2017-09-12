//
//  PostToColorV3MigrationPolicy.swift
//  CoreDataMigration-Example
//
//  Created by William Boles on 12/09/2017.
//  Copyright © 2017 William Boles. All rights reserved.
//

import CoreData

final class Post2ToPost3MigrationPolicy: NSEntityMigrationPolicy {
    
    override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        try super.createDestinationInstances(forSource: sInstance, in: mapping, manager: manager)

        guard let destinationPost = manager.destinationInstances(forEntityMappingName: mapping.name, sourceInstances: [sInstance]).first else {
            fatalError("was expected a post")
        }
        
        let color = NSEntityDescription.insertNewObject(forEntityName: "Color", into: destinationPost.managedObjectContext!)
        color.setValue(UUID().uuidString, forKey: "colorID")
        color.setValue(sInstance.value(forKey: "hexColor"), forKey: "hex")
        
        destinationPost.setValue(color, forKey: "color")
    }
}
