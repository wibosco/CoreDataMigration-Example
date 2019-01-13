//
//  PostViewerViewController.swift
//  CoreDataMigration-Example
//
//  Created by William Boles on 13/01/2019.
//  Copyright © 2019 William Boles. All rights reserved.
//

import UIKit

class PostViewerViewController: UIViewController {

    var post: Post!
    
    @IBOutlet var textView: UITextView!
    
    // MARK: - ViewLifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        textView.text = post.content!
    }
}
