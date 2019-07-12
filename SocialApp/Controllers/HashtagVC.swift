//
//  HashtagVC.swift
//  SocialApp
//
//  Created by Bold Lion on 31.10.18.
//  Copyright © 2018 Bold Lion. All rights reserved.
//

import UIKit
import SVProgressHUD

class HashtagVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var posts = [Post]()
    
    lazy var tag: String = {
        let string = String()
        return string
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "#" + tag
        collectionView.dataSource = self
        collectionView.delegate = self
        loadPosts()
    }
    
    func loadPosts() {
        Api.Hashtag.fetchPostsForTag(withTag: tag, completion: { postId in
            Api.Post.observePostSingleEvent(withId: postId, completion: { [unowned self] post in
                self.posts.append(post)
                self.collectionView.reloadData()
            }, onError: { error in
                SVProgressHUD.showError(withStatus: error)
            })
        })
    }
    
}

extension HashtagVC: UICollectionViewDataSource {
    
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
}

extension HashtagVC : UICollectionViewDelegateFlowLayout {
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

extension HashtagVC: PhotoCVCellDelegate {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "HashtagToDetail" {
            let detailVC = segue.destination as! DetailVC
            let postId = sender as! String
            detailVC.postId = postId
        }
    }
    
    func goToDetailVC(withId id: String) {
        performSegue(withIdentifier: "HashtagToDetail", sender: id)
    }
}
