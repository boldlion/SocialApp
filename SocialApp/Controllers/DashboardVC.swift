//
//  DashboardVC.swift
//  SocialApp
//
//  Created by Bold Lion on 30.09.18.
//  Copyright © 2018 Bold Lion. All rights reserved.
//

import UIKit
import SVProgressHUD

class DashboardVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var posts = [Post]()
    var users = [UserModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        navigationItem.title = "Dashboard"
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        fetchPosts()
    }
    
    func fetchPosts() {
        activityIndicator.startAnimating()
        Api.Post.observeAllPosts(completion: { post in
            guard let uid = post.uid else { return }
            self.fetchUserOfPost(with: uid, completion: {
                self.posts.insert(post, at: 0)
                self.activityIndicator.stopAnimating()
                self.activityIndicator.hidesWhenStopped = true
                self.tableView.reloadData()
            })
        }, onError: { error in
            SVProgressHUD.showError(withStatus: error)
        })
    }
    
    func fetchUserOfPost(with uid: String, completion: @escaping () -> Void) {
        Api.Users.fetchUser(withId: uid, completion: { user in
            self.users.insert(user, at: 0)
            completion()
        }, onError: { error in
            SVProgressHUD.showError(withStatus: error)
        })
    }
}

extension DashboardVC :  UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! DashboardTVCell
        let post = posts[indexPath.row]
        let user = users[indexPath.row]
        cell.post = post
        cell.user = user
        cell.delegateShowComment = self
        return cell
    }
}


extension DashboardVC : ShowCommentProtocol {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DashboardToComment" {
            let commentVC = segue.destination as! CommentVC
            let postId = sender as! String
            commentVC.postId = postId
        }
    } 
    
    func showCommentForPost(with id: String) {
        performSegue(withIdentifier: "DashboardToComment", sender: id)
    }

}
