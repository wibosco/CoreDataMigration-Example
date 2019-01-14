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
        
        let sourceBody = sInstance.value(forKey: "content") as? String
        let sourceTitle = sourceBody?.prefix(80)
        let sourceHexColor = sInstance.value(forKey: "hexColor")
        
        let titleContent = NSEntityDescription.insertNewObject(forEntityName: "Content", into: destinationPost.managedObjectContext!)
        titleContent.setValue(sourceTitle, forKey: "content")
        titleContent.setValue(sourceHexColor, forKey: "hexColor")
        titleContent.setValue(destinationPost, forKey: "post")
        destinationPost.setValue(titleContent, forKey: "title")
        
        let bodyContent = NSEntityDescription.insertNewObject(forEntityName: "Content", into: destinationPost.managedObjectContext!)
        bodyContent.setValue(sourceBody, forKey: "content")
        bodyContent.setValue(sourceHexColor, forKey: "hexColor")
        bodyContent.setValue(destinationPost, forKey: "post")
        destinationPost.setValue(bodyContent, forKey: "body")
    }
}
