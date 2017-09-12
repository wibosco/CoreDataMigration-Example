//
//  ViewController.swift
//  CoreDataMigration-Example
//
//  Created by William Boles on 11/09/2017.
//  Copyright © 2017 William Boles. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UITableViewController {

    var posts = [Post]()
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        
        return dateFormatter
    }()
    
    // MARK: - ViewLifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 80.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadData()
    }
    
    // MARK: - ButtonActions
    
    @IBAction func addButtonPressed(_ sender: Any) {
        addPost {
            self.loadData()
        }
    }
    
    // MARK: - Post
    
    func addPost(completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let coreDataManager: CoreDataManager = CoreDataManager.shared
            let context = coreDataManager.backgroundContext
            context.performAndWait {
                let post = NSEntityDescription.insertNewObject(forEntityName: "Post", into: context) as! Post
                post.postID = UUID().uuidString
                post.date = Date()
                post.color = UIColor.random.hexString
                
                try! context.save()
                
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
    
    // MARK: - Load
    
    func loadData() {
        let context = CoreDataManager.shared.mainContext
        let request = NSFetchRequest<Post>.init(entityName: "Post")
        let dateSort = NSSortDescriptor(key: "date", ascending: false)
        
        request.sortDescriptors = [dateSort]
        posts = try! context.fetch(request)
        
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell", for: indexPath) as! PostTableViewCell
        
        cell.postIDLabel.text = post.postID
        cell.dateLabel.text = dateFormatter.string(from: post.date!)
        cell.contentView.backgroundColor = UIColor.colorWithHex(hexColor: post.color!)
        
        return cell
    }
}
