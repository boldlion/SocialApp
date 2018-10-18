//
//  SearchVC.swift
//  SocialApp
//
//  Created by Bold Lion on 14.10.18.
//  Copyright © 2018 Bold Lion. All rights reserved.
//

import UIKit
import SVProgressHUD

class SearchVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var searchBar = UISearchBar()
    var users = [UserModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        doSearch()
    }
    
    func setupSearchBar() {
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search for username"
        searchBar.frame.size.width = view.frame.size.width - 55
        let searchItem = UIBarButtonItem(customView: searchBar)
        self.navigationItem.rightBarButtonItem = searchItem
    }
    
    func doSearch() {
        if let searchText = searchBar.text?.lowercased() {
            self.users.removeAll()
            self.tableView.reloadData()
            Api.Users.queryUsers(withtext: searchText, onError: { error in
                SVProgressHUD.showError(withStatus: error)
            }, completion: { user in
                guard let uid = user.id else { return }
           
                self.isFollowing(userId: uid, completion: { isFollowing in
                    user.isFollowing = isFollowing
                    self.users.append(user)
                    self.tableView.reloadData()
                })
           })
        }
    }
    
    func isFollowing(userId: String, completion: @escaping (Bool) -> Void) {
        Api.Follow.isFollowing(userId: userId, completion: completion, onError: { error in
            SVProgressHUD.showError(withStatus: error)
        })
    }
}

extension SearchVC : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        doSearch()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        doSearch()
    }
}

extension SearchVC : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DiscoverTVCell", for: indexPath) as! DiscoverTVCell
        let user = users[indexPath.row]
        cell.user = user
        cell.delegateShowUserProfile = self
        return cell
    }
}

extension SearchVC: DiscoverTVCellDelegate {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SearchToProfileUser" {
            let profileUserVC = segue.destination as! ProfileUserVC
            let userId = sender as! String
            profileUserVC.userId = userId
            profileUserVC.delegate = self
        }
    }
    
    func goToUserProfile(withId id: String) {
        performSegue(withIdentifier: "SearchToProfileUser", sender: id)
    }
    
}

extension SearchVC: HeaderProfileCollectionReusableViewDelegate {
    func updateFollowButton(forUser user: UserModel) {
        for u in users {
            if u.id == user.id {
                u.isFollowing = user.isFollowing
                tableView.reloadData()
            }
        }
    }
    
    
}
