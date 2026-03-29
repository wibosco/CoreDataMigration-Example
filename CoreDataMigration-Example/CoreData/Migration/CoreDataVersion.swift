//
//  CoreDataVersion.swift
//  CoreDataMigration-Example
//
//  Created by William Boles on 29/03/2026.
//  Copyright © 2026 William Boles. All rights reserved.
//

import Foundation

enum CoreDataVersion: String, CaseIterable {
    case version1 = "CoreDataMigration_Example"
    case version2 = "CoreDataMigration_Example 2"
    case version3 = "CoreDataMigration_Example 3"
    case version4 = "CoreDataMigration_Example 4"
    
    static var latest: CoreDataVersion {
        return allCases.last!
    }
}
