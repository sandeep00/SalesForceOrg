//
//  CreateCommentViewController.swift
//  Salesforce
//
//  Created by Bindu on 11/27/18.
//  Copyright © 2018 Sandeep. All rights reserved.
//

import UIKit

class CreateCommentViewController: UIViewController {

    @IBOutlet fileprivate(set) weak var inputArea: UITextView!
    
    @IBOutlet fileprivate(set) weak var isPublic: UISwitch!
    
    
    @IBAction func addComment(_ sender: UIButton) {
        
        let comment = Comment()
        
        comment.message = inputArea.text
        
        comment.isPublic = isPublic.isOn
        
        CommentsModel().create(comment: comment){ (error, id) in
            
            if let error = error {
                
                let alertController = UIAlertController(title: "Could not create the comment",
                                                        message: error.errorDescription,
                                                        preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                self.present(alertController, animated: true, completion: nil)
                
            }
            else {
                
                self.navigationController?.popViewController(animated: true)
                
            }
        }
    }
    
    @IBAction func dismiss(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
}
