//
//  RepliesTableViewController.swift
//  Salesforce
//
//  Created by Bindu on 11/17/18.
//  Copyright © 2018 Sandeep. All rights reserved.
//

import UIKit

/*
 Provides CommentDetail and ability to edit comment in line.
 */
class CommentDetailTableViewController: UITableViewController {
    
    var commentId: String?
    
    private var reSizeingCellHeight: CGFloat = 200
    
    @IBOutlet weak var replyTextBox: UITextView!
    
    private let commentModel = CommentsModel()
    
    private var editedText: String?
    
    private var editedIndexPath: IndexPath?
    
    private var commentData: CommentProtocol? {
        didSet {
            
            tableView.reloadData()
        }
    }
        

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let customBackButton = UIBarButtonItem(title: "Back", style: .plain, target:self, action: #selector(backButtonPressed))
        
        self.navigationItem.leftBarButtonItem = customBackButton
        
        registerKeyboardNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        fetchCommentDetail()
    }
    
    @objc private func backButtonPressed() {
        
        if editedText == nil {
            self.navigationController?.popViewController(animated: true)
        }
        
        else {
            
            let alert = UIAlertController(title: "", message: "Save changes", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "No", style: .cancel) { (action) in
                
                self.navigationController?.popViewController(animated: true)
                
            }
            
            let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] (action) in
                
                guard let weakSelf = self else {
                    return
                }
                
                var editedCommentId = ""
                
                if let editedIndexPath = weakSelf.editedIndexPath {
                    if editedIndexPath.section == 1 {
                        editedCommentId = (weakSelf.commentData?.children[editedIndexPath.row].id)!
                    }
                    else {
                        editedCommentId = weakSelf.commentId!
                    }
                }
                
                weakSelf.commentModel.edit(weakSelf.editedText!, commentId: editedCommentId, isPublic: false) {
                    
                    [weak self] (error, commentDetails) in
                    
                    guard let weakSelf = self else {
                        return
                    }
                    
                    if let error = error {
                        
                        let alertController = UIAlertController(title: "Could not save the edit",
                                                                message: error.errorDescription,
                                                                preferredStyle: .alert)
                        
                        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                        
                        weakSelf.present(alertController, animated: true, completion: nil)
                        
                    }
                    else {
                        
                        weakSelf.navigationController?.popViewController(animated: true)
                        
                    }
                    
                }
            }
            
            alert.addAction(saveAction)
            
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true, completion: nil)
        }
        
       
    }
    
    @IBAction func submitReply(_ sender: UIButton) {
        
        guard let commentId = commentId else {
            return
        }
        
        commentModel.reply(replyTextBox.text, parentId: commentId) { [weak self] (error, commentDetails) in
            
            guard let weakSelf = self else {
                return
            }
            
            weakSelf.replyTextBox.text = ""
            
            if let error = error {
                
                let alertController = UIAlertController(title: "Could not fetch comment Data",
                                                        message: error.errorDescription,
                                                        preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                weakSelf.present(alertController, animated: true, completion: nil)
                
            }
            else {
                
                 weakSelf.fetchCommentDetail()
                
            }
        }
    }
    
    fileprivate func fetchCommentDetail() {
        
        guard let commentId = commentId else {
            return
        }
        
        commentModel.detail(for: commentId) { [weak self] (error, commentDetails) in
            
            guard let weakSelf = self else {
                return
            }
            
            if let error = error {
                
                let alertController = UIAlertController(title: "Could not fetch comment Data",
                                                        message: error.errorDescription,
                                                        preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                weakSelf.present(alertController, animated: true, completion: nil)
                
            }
            else {
                
                if let detail = commentDetails {
                    
                   weakSelf.commentData = detail
                }
            }
        }
    }
}

typealias CommentDetailDataSource = CommentDetailTableViewController
extension CommentDetailDataSource {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
         return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        }
        
        if let commentInfo = commentData {
            return commentInfo.children.count
        }
        
        return 0
    }
}

typealias CommentDetailTableViewDelegate = CommentDetailTableViewController
extension CommentDetailTableViewDelegate {
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 0 {
            return NSLocalizedString("Comment", comment: "")
        }
        
        return  NSLocalizedString("Replies", comment: "")
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "commentDetailCell", for: indexPath) as? AutoSizingTableViewCell else {
            fatalError("Could not dequeue commentCell")
        }
    
        if indexPath.section == 0 {
            if let commentInfo = commentData {
                cell.textView.text = commentInfo.message
            }
        }
       
        if indexPath.section == 1 {
            if let commentInfo = commentData, commentInfo.children.count > indexPath.row {
                    cell.textView.text = commentInfo.children[indexPath.row].message
            }
        }
        
        cell.delegate = self
        
        cell.indexPath = indexPath
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

typealias CommentDetailSwipeActions = CommentDetailTableViewController
extension CommentDetailSwipeActions {
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if indexPath.section == 0 {
            return nil
        }
        
        let deleteAction = contextualDeleteAction(forRowAtIndexPath: indexPath)
        let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeConfig
    }
    
    private func contextualDeleteAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        
        let id: String
        
        guard var commentData = commentData else {
            fatalError("Invalid state")
        }
        
        if indexPath.section == 0, let commentId = commentId {
            id = commentId
        }
        else {
           
            id = commentData.children[indexPath.row].id
        }
        
        let action = UIContextualAction(style: .destructive, title: "Delete") { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: @escaping (Bool) -> Void) in
            
            let commentModel = CommentsModel()
            
            commentModel.delete(id, completion: { [weak self] (error, comment) in
                
                guard let weakSelf = self else {
                    return
                }
                
                if let error = error {
                    let alertController = UIAlertController(title: "Could not create the comment",
                                                            message: error.errorDescription,
                                                            preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    
                    weakSelf.present(alertController, animated: true, completion: nil)
                }
                else {
                    commentData.children.remove(at: indexPath.row)
    
                    weakSelf.tableView.deleteRows(at: [indexPath], with: .left)
    
                    completionHandler(true)
                }
            })
        }
        
        return action
    }
}

typealias CommentDetailKeyboardActions = CommentDetailTableViewController
extension CommentDetailKeyboardActions {
    
    fileprivate func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: .UIKeyboardWillChangeFrame, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        guard let userInfo = notification.userInfo,
            let keyBoardValueBegin = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue,
            let keyBoardValueEnd = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue, keyBoardValueBegin != keyBoardValueEnd else {
                return
        }
        
        let keyboardHeight = keyBoardValueEnd.height
        
        tableView.contentInset.bottom = keyboardHeight
    }
}

typealias ResizeTableViewCell = CommentDetailTableViewController
extension ResizeTableViewCell: AutoSizingTableViewCellDelegate {
    
    func resized(height: CGFloat, modifiedText: String, editedIndexPath: IndexPath?) {
        
        UIView.setAnimationsEnabled(false)
        
        tableView.beginUpdates()
        
        tableView.endUpdates()
        
        UIView.setAnimationsEnabled(true)

        let indexPath = IndexPath(row: 0, section: 0)
        
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        
        editedText = modifiedText
        
        self.editedIndexPath = editedIndexPath
    }
}
