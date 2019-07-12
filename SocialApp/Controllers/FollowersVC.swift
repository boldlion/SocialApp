//
//  FollowersVC.swift
//  SocialApp
//
//  Created by Bold Lion on 4.11.18.
//  Copyright © 2018 Bold Lion. All rights reserved.
//

import UIKit
import SVProgressHUD

class FollowersVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    lazy var userId: String = {
        return String()
    }()
    
    lazy var users: [UserModel] = {
        return [UserModel]()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Followers"
        tableView.dataSource = self
        fetchFollowers()
    }
    
    func fetchFollowers() {
        Api.Follow.fetchFollowers(forUserId: userId, completion: { followerId in
            Api.Users.fetchUser(withId: followerId, completion: { [unowned self] user in
                guard let uid = user.id else { return }
                self.isFollowing(userId: uid, completion: { [unowned self] isFollowing in
                    user.isFollowing = isFollowing
                    self.users.append(user)
                    self.tableView.reloadData()
                })
            }, onError: { error in
                SVProgressHUD.showError(withStatus: error)
            })
        })
    }
    
    func isFollowing(userId: String, completion: @escaping (Bool) -> Void) {
        Api.Follow.isFollowing(userId: userId, completion: completion, onError: { error in
            SVProgressHUD.showError(withStatus: error)
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FollowersVCToProfileUserVC" {
            let profileUserVC = segue.destination as! ProfileUserVC
            let userId = sender as! String
            profileUserVC.userId = userId
            profileUserVC.delegate = self
        }
    }
}

extension FollowersVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DiscoverTVCell", for: indexPath) as! DiscoverTVCell
        let user = users[indexPath.row]
        cell.delegateShowUserProfile = self
        cell.user = user
        return cell
    }
}


extension FollowersVC: DiscoverTVCellDelegate {
    
    func goToUserProfile(withId id: String) {
        performSegue(withIdentifier: "FollowersVCToProfileUserVC", sender: id)
    }
}

extension FollowersVC: HeaderProfileCollectionReusableViewDelegate {
    
    func updateFollowButton(forUser user: UserModel) {
        for u in users {
            if u.id == user.id {
                u.isFollowing = user.isFollowing
                tableView.reloadData()
            }
        }
    }
}
