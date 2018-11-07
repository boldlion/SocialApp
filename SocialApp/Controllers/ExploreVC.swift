//
//  ExploreVC.swift
//  SocialApp
//
//  Created by Bold Lion on 14.10.18.
//  Copyright © 2018 Bold Lion. All rights reserved.
//

import UIKit
import SVProgressHUD
class ExploreVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var refresh: UIRefreshControl!
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        fetchTopPosts()
        setRefreshControl()
    }
    
    @IBAction func refresh(_ sender: UIBarButtonItem) {
        fetchTopPosts()
    }
    
    func fetchTopPosts() {
        posts.removeAll()
        collectionView.reloadData()
        Api.Post.observeTopPosts(completion: { post in
            SVProgressHUD.dismiss()
            self.posts.append(post)
            self.collectionView.reloadData()
        }, onError: { error in
            SVProgressHUD.showError(withStatus: error)
        })
    }
    
    func setRefreshControl() {
        refresh = UIRefreshControl()
        collectionView.alwaysBounceVertical = true
        refresh.tintColor = Colors.tint
        refresh.addTarget(self, action: #selector(refreshPosts), for: .valueChanged)
        collectionView.addSubview(refresh)
    }
    
    @objc func refreshPosts() {
        fetchTopPosts()
        self.refresh.endRefreshing()
    }
}

extension ExploreVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExploreCVCell", for: indexPath) as! PhotoCVCell
        let post = posts[indexPath.row]
        cell.delegate = self
        cell.post = post
        return cell
    }
}

extension ExploreVC : UICollectionViewDelegateFlowLayout {
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

extension ExploreVC: PhotoCVCellDelegate {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ExploreToDetailVCSegue" {
            let detailVC = segue.destination as! DetailVC
            let postId = sender as! String
            detailVC.postId = postId
        }
    }
    
    func goToDetailVC(withId id: String) {
        performSegue(withIdentifier: "ExploreToDetailVCSegue", sender: id)
    }   
}
