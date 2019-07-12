//
//  ActivityVC.swift
//  SocialApp
//
//  Created by Bold Lion on 6.11.18.
//  Copyright © 2018 Bold Lion. All rights reserved.
//

import UIKit
import SVProgressHUD

class ActivityVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var notifications = [NotificationC]()
    var users = [UserModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        fetchNotifications()
    }
    
    func fetchNotifications() {
        Api.Notification.observeNotifications(completion: { [unowned self] notification in
            guard let uid = notification.from else { return }
            self.fetchUserOfNotification(with: uid, completion: { [unowned self] in
                self.notifications.insert(notification, at: 0)
                self.tableView.reloadData()
            })
        }, onError: { error in
           SVProgressHUD.showError(withStatus: error)
        })
    }
    
    func fetchUserOfNotification(with uid: String, completion: @escaping () -> Void) {
        Api.Users.fetchUser(withId: uid, completion: { [unowned self] user in
            self.users.insert(user, at: 0)
            completion()
        }, onError: { error in
            SVProgressHUD.showError(withStatus: error)
        })
    }
}


extension ActivityVC : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityTVCell", for: indexPath) as! ActivityTVCell
        cell.user = users[indexPath.row]
        cell.notification = notifications[indexPath.row]
        cell.delegate = self
        return cell
    }
}

extension ActivityVC : ActivityTVCellDelegate {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ActivityVCToDetailVC" {
            let detailVC = segue.destination as! DetailVC
            let postId = sender as! String
            detailVC.postId = postId
        }
    }
    
    func goToDetailVC(withPostId id: String) {
        performSegue(withIdentifier: "ActivityVCToDetailVC", sender: id)
    }
}
