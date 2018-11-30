//
//  CommentTableViewCell.swift
//  Salesforce
//
//  Created by Bindu on 11/29/18.
//  Copyright © 2018 Sandeep. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {


    @IBOutlet fileprivate(set) weak var message: UILabel!
    
    @IBOutlet fileprivate(set) weak var createdBy: UILabel!
    
    @IBOutlet fileprivate(set) weak var numberOfReplies: UILabel!
    
    func configure(_ comment: CommentProtocol) {
        message.text = comment.message
        createdBy.text =  NSLocalizedString("Created by: ", comment: "") + comment.author
        numberOfReplies.text = NSLocalizedString("Replies: ", comment: "") + String(comment.children.count)
    }

}
