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

    @IBOutlet weak var textView: UITextView!
    
    // MARK: - ViewLifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.text = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardDidShowNotification, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Keyboard
    
    @objc func keyboardWillAppear(_ notification: NSNotification) {
        let keyboardRect = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let rect = textView.convert(keyboardRect, from: nil)
        
        textView.contentInset.bottom = rect.size.height
        textView.scrollIndicatorInsets.bottom = rect.size.height
    }
    
    // MARK: - ButtonActions
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        let content = textView.text
        DispatchQueue.global(qos: .userInitiated).async {
            let context = CoreDataManager.shared.backgroundContext
            context.performAndWait {
                let post = NSEntityDescription.insertNewObject(forEntityName: "Post", into: context) as! Post
                post.postID = UUID().uuidString
                post.date = Date()
                post.content = content
                post.color = UIColor.random.hexString

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
