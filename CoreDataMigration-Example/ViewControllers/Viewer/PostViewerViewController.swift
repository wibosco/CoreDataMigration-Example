//
//  PostViewerViewController.swift
//  CoreDataMigration-Example
//
//  Created by William Boles on 13/01/2019.
//  Copyright © 2019 William Boles. All rights reserved.
//

import UIKit
import CoreData

struct PostViewerViewModel {
    
    let postID: String
    let title: String
    let body: String
    let titleBackgroundColor: UIColor
    let bodyBackgroundColor: UIColor
}

class PostViewerViewController: UIViewController {

    var viewModel: PostViewerViewModel!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var bodyTextView: UITextView!
    
    // MARK: - ViewLifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        titleLabel.backgroundColor = viewModel.titleBackgroundColor
        titleLabel.text = viewModel.title
        
        bodyTextView.backgroundColor = viewModel.bodyBackgroundColor
        bodyTextView.text = viewModel.body
    }
    
    // MARK: - ButtonActions
    
    @IBAction func hideButtonPressed(_ sender: Any) {
        DispatchQueue.global(qos: .userInitiated).async {
            let context = CoreDataManager.shared.backgroundContext
            context.performAndWait {
                let request = NSFetchRequest<Post>.init(entityName: "Post")
                request.predicate = NSPredicate(format: "postID == '\(self.viewModel.postID)'")
                
                let post = try! context.fetch(request).first!
                post.hidden = true
                
                try? context.save()
                
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}
