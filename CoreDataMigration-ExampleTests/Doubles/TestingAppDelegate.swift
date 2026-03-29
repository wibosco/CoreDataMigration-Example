//
//  TestingAppDelegate.swift
//  CoreDataMigration-ExampleTests
//
//  Created by William Boles on 15/09/2017.
//  Copyright © 2017 William Boles. All rights reserved.
//

import UIKit
import CoreData

@testable import CoreDataMigration_Example

class TestingAppDelegate: NSObject, UIApplicationDelegate {
    
    var window: UIWindow?
    
    // MARK: - AppLifecycle
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        //Just some house keeping
        if let storeURL = CoreDataManager().persistentContainer.persistentStoreDescriptions.first?.url {
            NSPersistentStoreCoordinator.destroyStore(at: storeURL)
        }
        
        return true
    }
}
