//
//  ProfileVC.swift
//  SocialApp
//
//  Created by Bold Lion on 30.09.18.
//  Copyright © 2018 Bold Lion. All rights reserved.
//

import UIKit
import SVProgressHUD

class ProfileVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var user: UserModel!
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        fetchUser()
        fetchUserPosts()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: UIBarButtonItem.Style.plain, target: self, action: nil)
    }
    
    func fetchUser() {
        Api.Users.observeCurrentUser(completion: { [unowned self] user in
            self.user = user
            self.navigationItem.title = user.displayName
            self.collectionView.reloadData()
        }, onError: { error in
            SVProgressHUD.showError(withStatus: error)
        })
    }
    
    func fetchUserPosts() {
        Api.User_Posts.observeCurrentUserPosts(completion: { postId in
            Api.Post.observePostSingleEvent(withId: postId, completion: { [unowned self] post in
                self.posts.append(post)
                self.collectionView.reloadData()
            }, onError: { postError in
                SVProgressHUD.showError(withStatus: postError)
            })
        }, onError: { error in
            SVProgressHUD.showError(withStatus: error)
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProfileToSettingsSegue" {
            let settingsVC = segue.destination as! SettingTVC
            settingsVC.delegate = self
        }
        if segue.identifier == "ProfileToDetailVC" {
            let detailVC = segue.destination as! DetailVC
            let postId = sender as! String
            detailVC.postId = postId
        }
        if segue.identifier == "ProfileVCToFollowersVC" {
            let followersVC = segue.destination as! FollowersVC
            let userId = sender as! String
            followersVC.userId = userId
        }
        if segue.identifier == "ProfileVCToFollowingVC" {
            let followingVC = segue.destination as! FollowingVC
            let userId = sender as! String
            followingVC.userId = userId
        }
        
    }
}

extension ProfileVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCVCell", for: indexPath) as! PhotoCVCell
        let post = posts[indexPath.row]
        cell.post = post
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderProfileCollectionReusableView", for: indexPath) as! HeaderProfileCollectionReusableView
        if let currentUser = user {
            header.user = currentUser
            header.delegateSettings = self
            header.delegateShowFollowersAndFollowing = self
        }
        return header
    }
}

extension ProfileVC : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 8) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
    }
}


extension ProfileVC : HeaderProfileCollectionReusableViewDelegateSwitchToSettingTVC {
    func goToSettingVC() {
        performSegue(withIdentifier: "ProfileToSettingsSegue", sender: nil)
    }
}

extension ProfileVC: HeaderProfileShowFollowersAndFollowingDelegate {
    func showFollowingForUser(withId id: String) {
        performSegue(withIdentifier: "ProfileVCToFollowingVC", sender: id)
    }
    
    func showFollowersForUser(withId id: String) {
        performSegue(withIdentifier: "ProfileVCToFollowersVC", sender: id)
    }
}

extension ProfileVC : SettingsTVCDelegate {
    func updateUserInfo() {
        fetchUser()
    }
}

extension ProfileVC : PhotoCVCellDelegate {
    func goToDetailVC(withId id: String) {
        performSegue(withIdentifier: "ProfileToDetailVC", sender: id)
    }
}

