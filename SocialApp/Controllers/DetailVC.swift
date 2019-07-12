//
//  DetailVC.swift
//  SocialApp
//
//  Created by Bold Lion on 16.10.18.
//  Copyright © 2018 Bold Lion. All rights reserved.
//

import UIKit
import SVProgressHUD

class DetailVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var postId = ""
    lazy var user: UserModel = {
        return UserModel()
    }()
    
    lazy var post: Post = {
        return Post()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        fetchPost()
    }
    
    func fetchPost() {
        Api.Post.observePostSingleEvent(withId: postId, completion: { [unowned self] post in
            self.post = post
            guard let uid = post.uid else { return }
            self.fetchUserOfPost(with: uid, completion: { [unowned self] in
                self.tableView.reloadData()
            })
        }, onError: { error in
            SVProgressHUD.showError(withStatus: error)
        })
    }
    
    func fetchUserOfPost(with uid: String, completion: @escaping () -> Void) {
        Api.Users.fetchUser(withId: uid, completion: { [unowned self] user in
            self.user = user
            completion()
        }, onError: { error in
            SVProgressHUD.showError(withStatus: error)
        })
    }
}

 extension DetailVC :  UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! DashboardTVCell
        cell.post = post
        cell.user = user
        cell.delegate = self
        return cell
    }
}

extension DetailVC : DashboardTVCellDelegate {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailToComment" {
            let commentVC = segue.destination as! CommentVC
            let postId = sender as! String
            commentVC.postId = postId
        }
        
        if segue.identifier == "DetailToProfileUser" {
            let profileUserVC = segue.destination as! ProfileUserVC
            let userId = sender as! String
            profileUserVC.userId = userId
        }
        
        if segue.identifier == "DetailToHashtag" {
            let hashtagVC = segue.destination as! HashtagVC
            let tag = sender as! String
            hashtagVC.tag = tag
        }
    }
    
    func showCommentForPost(with id: String) {
        performSegue(withIdentifier: "DetailToComment", sender: id)
    }
    
    func goToProfile() {
        performSegue(withIdentifier: "DetailToProfile", sender: nil)
    }
    
    func goToProfileUser(with id: String) {
        performSegue(withIdentifier: "DetailToProfileUser", sender: id)
    }
    
    func goToHashtag(tag: String) {
        performSegue(withIdentifier: "DetailToHashtag", sender: tag)
    }
    
}
