//
//  DiscoverVC.swift
//  SocialApp
//
//  Created by Bold Lion on 12.10.18.
//  Copyright © 2018 Bold Lion. All rights reserved.
//

import UIKit
import SVProgressHUD

class DiscoverVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var users = [UserModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        fetchUsers()
        title = "Discover"
    }
    
    func fetchUsers() {
        Api.Users.fetchAllUsers(completion: { user in
            guard let currentUserId = Api.Users.CURRENT_USER?.uid else { return }
            guard let uid = user.id else { return }
            
            if currentUserId != user.id {
                self.isFollowing(userId: uid, completion: { isFollowing in
                    user.isFollowing = isFollowing
                    self.users.append(user)
                    self.tableView.reloadData()
                })
            }
        }, onError: { error in
            SVProgressHUD.showError(withStatus: error)
        })
    }
    
    func isFollowing(userId: String, completion: @escaping (Bool) -> Void) {
        Api.Follow.isFollowing(userId: userId, completion: completion, onError: { error in
            SVProgressHUD.showError(withStatus: error)
        })
    }
    
}
extension DiscoverVC : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DiscoverTVCell", for: indexPath) as! DiscoverTVCell
        let user = users[indexPath.row]
        cell.user = user
        return cell
    }
}
