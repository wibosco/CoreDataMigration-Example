//
//  PostTableViewCell.swift
//  CoreDataMigration-Example
//
//  Created by William Boles on 11/09/2017.
//  Copyright © 2017 William Boles. All rights reserved.
//

import UIKit

struct PostTableViewCellViewModel {
    
    let body: String
    let date: String
    let color: UIColor
}

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    // MARK: - Configure
    
    func configure(withViewModel viewModel: PostTableViewCellViewModel) {
        bodyLabel.text = viewModel.body
        dateLabel.text = viewModel.date
        contentView.backgroundColor = viewModel.color
    }
    
}
