//
//  PostWriterViewController.swift
//  CoreDataMigration-Example
//
//  Created by William Boles on 13/01/2019.
//  Copyright © 2019 William Boles. All rights reserved.
//

import UIKit
import CoreData

class PostWriterViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var bodyTextView: UITextView!
    
    // MARK: - ViewLifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        titleTextField.text = nil
        bodyTextView.text = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        titleTextField.becomeFirstResponder()
    }
    
    // MARK: - Keyboard
    
    @objc func keyboardWillAppear(_ notification: NSNotification) {
        let keyboardRect = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let rect = bodyTextView.convert(keyboardRect, from: nil)
        
        bodyTextView.contentInset.bottom = rect.size.height
        bodyTextView.scrollIndicatorInsets.bottom = rect.size.height
    }
    
    // MARK: - ButtonActions
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        let title = titleTextField.text
        let body = bodyTextView.text
        DispatchQueue.global(qos: .userInitiated).async {
            let context = CoreDataManager.shared.backgroundContext
            context.performAndWait {
                let post = NSEntityDescription.insertNewObject(forEntityName: "Post", into: context) as! Post
                post.postID = UUID().uuidString
                post.date = Date()
                
                let titleContent = NSEntityDescription.insertNewObject(forEntityName: "Content", into: context) as! Content
                titleContent.content = title
                titleContent.hexColor = UIColor.random.hexString

                post.title = titleContent
                
                let bodyContent = NSEntityDescription.insertNewObject(forEntityName: "Content", into: context) as! Content
                bodyContent.content = body
                bodyContent.hexColor = UIColor.random.hexString
                
                post.body = bodyContent
                
                try? context.save()
                
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
