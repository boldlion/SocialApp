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
        tableView.estimatedRowHeight = 428
        tableView.rowHeight = UITableView.automaticDimension
        fetchPosts()
    }
    
    func fetchPosts() {
        activityIndicator.startAnimating()
        
        Api.Feed.observeFeedPosts(completion: { post in
            guard let uid = post.uid else { return }
            self.fetchUserOfPost(with: uid, completion: {
                self.posts.append(post)
                self.activityIndicator.stopAnimating()
                self.activityIndicator.hidesWhenStopped = true
                self.tableView.reloadData()
            })
        }, onError: { error in
             SVProgressHUD.showError(withStatus: error)
        })
        
        
        Api.Feed.observeFeedRemoved(completion: { post in
            self.posts = self.posts.filter({ $0.id != post.id })
            self.users = self.users.filter({ $0.id != post.uid })
            self.tableView.reloadData()
        }, onError: { error in
            SVProgressHUD.showError(withStatus: error)
        })
    }
    
    func fetchUserOfPost(with uid: String, completion: @escaping () -> Void) {
        Api.Users.fetchUser(withId: uid, completion: { user in
            self.users.append(user)
            completion()
        }, onError: { error in
            SVProgressHUD.showError(withStatus: error)
        })
    }
}

extension DashboardVC :  UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! DashboardTVCell
        let post = posts[indexPath.row]
        let user = users[indexPath.row]
        cell.post = post
        cell.user = user
        cell.delegate = self
        return cell
    }
}

extension DashboardVC : DashboardTVCellDelegate {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DashboardToComment" {
            let commentVC = segue.destination as! CommentVC
            let postId = sender as! String
            commentVC.postId = postId
        }
        
        if segue.identifier == "DashboardToProfileUser" {
            let profileUserVC = segue.destination as! ProfileUserVC
            let userId = sender as! String
            profileUserVC.userId = userId
        }
    } 
    
    func showCommentForPost(with id: String) {
        performSegue(withIdentifier: "DashboardToComment", sender: id)
    }
    
    func goToProfile() {
        performSegue(withIdentifier: "DashboardToProfile", sender: nil)
    }
    
    func goToProfileUser(with id: String) {
        performSegue(withIdentifier: "DashboardToProfileUser", sender: id)
    }
    
}
