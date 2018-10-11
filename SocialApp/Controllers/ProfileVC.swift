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
    }
    
    func fetchUser() {
        Api.Users.observeCurrentUser(completion: { user in
            self.user = user
            self.navigationItem.title = user.username
            self.collectionView.reloadData()
        }, onError: { error in
            SVProgressHUD.showError(withStatus: error)
        })
    }
    
    func fetchUserPosts() {
        Api.User_Posts.observeUserPosts(completion: { postId in
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
    
    @IBAction func logoutTapped(_ sender: UIBarButtonItem) {
        AuthApi.logout(onSuccess: {
            let storyboard = UIStoryboard(name: "Auth", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC")
            self.present(loginVC, animated: true, completion: nil)
        }, onError: { error in
            SVProgressHUD.showError(withStatus: error)
        })
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
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderProfileCollectionReusableView", for: indexPath) as! HeaderProfileCollectionReusableView
        if let currentUser = user {
            header.user = currentUser
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
