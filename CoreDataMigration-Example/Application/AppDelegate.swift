//
//  AppDelegate.swift
//  CoreDataMigration-Example
//
//  Created by William Boles on 11/09/2017.
//  Copyright © 2017 William Boles. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        guard NSClassFromString("XCTestCase") == nil else {
            return true
        }
        
        CoreDataManager.shared.setup {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // just for example purposes
                self.presentMainUI()
            }
        }
        
        return true
    }
    
    // MARK: - Main
    
    func presentMainUI() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        window?.rootViewController = mainStoryboard.instantiateInitialViewController()
    }
}
