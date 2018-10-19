//
//  ProfileUserVC.swift
//  SocialApp
//
//  Created by Bold Lion on 17.10.18.
//  Copyright © 2018 Bold Lion. All rights reserved.
//

import UIKit
import SVProgressHUD

class ProfileUserVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var user: UserModel!
    var posts = [Post]()
    var userId = ""
    var delegate: HeaderProfileCollectionReusableViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        fetchUser()
        fetchUserPosts()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: UIBarButtonItem.Style.plain, target: self, action: nil)
    }
    
    func fetchUser() {
        Api.Users.fetchUser(withId: userId, completion: { user in
            guard let uid = user.id else { return }
            self.user = user
            self.isFollowing(userId: uid, completion: { isFollowing in
                user.isFollowing = isFollowing
                self.navigationItem.title = user.displayName
                self.collectionView.reloadData()
            })
        }, onError: { error in
            SVProgressHUD.showError(withStatus: error)
        })
    }

    
    func isFollowing(userId: String, completion: @escaping (Bool) -> Void) {
        Api.Follow.isFollowing(userId: userId, completion: completion, onError: { error in
            SVProgressHUD.showError(withStatus: error)
        })
    }
    
    func fetchUserPosts() {
        Api.User_Posts.observeUserPosts(withUserId: userId, completion: { postId in
            Api.Post.observePostSingleEvent(withId: postId, completion: { post in
                self.posts.append(post)
                self.collectionView.reloadData()
            }, onError: { postError in
                SVProgressHUD.showError(withStatus: postError)
            })
        }, onError: { error in
            SVProgressHUD.showError(withStatus: error)
        })
    }
}


extension ProfileUserVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCVCell", for: indexPath) as! PhotoCVCell
        let post = posts[indexPath.row]
        cell.post = post
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderProfileCollectionReusableView", for: indexPath) as! HeaderProfileCollectionReusableView
        if let currentUser = user {
            header.user = currentUser
            header.delegate = self.delegate
            header.delegateSettings = self
        }
        return header
    }
}

extension ProfileUserVC : UICollectionViewDelegateFlowLayout {
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

extension ProfileUserVC : HeaderProfileCollectionReusableViewDelegateSwitchToSettingTVC {
    func goToSettingVC() {
        performSegue(withIdentifier: "ProfileUserToSettingsSegue", sender: nil)
    }
}
