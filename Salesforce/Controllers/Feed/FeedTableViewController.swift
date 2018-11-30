import UIKit

class FeedTableViewController: UITableViewController {
    
    var feed: FeedProtocol? {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupTableView()
    }
    
    @IBAction func logOut(_ sender: UIBarButtonItem) {
        
        AuthenticationModel().logOut()
        
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    private func setupTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 90
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        let commentModel = CommentsModel()
        
        commentModel.feed { [weak self] (error, feed) in
            
            guard let weakSelf = self else {
                return
            }
            
            weakSelf.feed = feed
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let feed = feed else {
            return
        }
        
        if segue.destination is CommentDetailTableViewController {
            if let vc = segue.destination as? CommentDetailTableViewController {
                if  let selectedIndexPath = tableView.indexPathForSelectedRow {
                    
                    let selectedRow = feed.comments[selectedIndexPath.row]
                    
                    vc.commentId = selectedRow.id
                }
            }
        }
    }
}

typealias FeedDataSource = FeedTableViewController
extension FeedDataSource {
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let feed = feed {
            return feed.comments.count
        }
        
        return 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as? CommentTableViewCell,
            let feed = feed else {
                fatalError("Could not dequeue commentCell")
        }
        
        cell.configure(feed.comments[indexPath.row])
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
}

typealias FeedSwipeActions = FeedTableViewController
extension FeedSwipeActions {
    
    private func contextualDeleteAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        
        guard var feed = feed else {
            fatalError("Invalid state")
        }
        
        let action = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (contextAction: UIContextualAction, sourceView: UIView, completionHandler: @escaping (Bool) -> Void) in
            
              let commentModel = CommentsModel()
            
              commentModel.delete(feed.comments[indexPath.row].id, completion: { [weak self] (error, comment) in
                
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
                    feed.comments.remove(at: indexPath.row)
                    
                    weakSelf.tableView.deleteRows(at: [indexPath], with: .left)
                    
                    completionHandler(true)
                }
            })
        }

        return action
    }


    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = contextualDeleteAction(forRowAtIndexPath: indexPath)
        let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeConfig
    }
}


