//
//  PostApi.swift
//  SocialApp
//
//  Created by Bold Lion on 3.10.18.
//  Copyright © 2018 Bold Lion. All rights reserved.
//

import FirebaseDatabase

class PostApi {
    
    let REF_POSTS = Database.database().reference().child("posts")
    
    func observeAllPosts(completion: @escaping (Post) -> Void, onError: @escaping (String) -> Void) {
        REF_POSTS.observe(.childAdded, with: { snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let post = Post.transformDataToPost(dictionary: dict, key: snapshot.key)
                completion(post)
            }
        }, withCancel: { error in
            onError(error.localizedDescription)
            return
        })
    }
    
    
    func observePostSingleEvent(withId id: String, completion: @escaping (Post) -> Void, onError: @escaping (String) -> Void) {
        REF_POSTS.child(id).observeSingleEvent(of: .value, with: { snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let post = Post.transformDataToPost(dictionary: dict, key: snapshot.key)
                completion(post)
            }
        }, withCancel: { error in
            onError(error.localizedDescription)
            return
        })
    }    
    
    func observePostForChanges(withId id: String, completion: @escaping (Int) -> Void, onError: @escaping (String) -> Void) {
        REF_POSTS.child(id).observe(.childChanged, with: { snapshot in
            if let value = snapshot.value as? Int {
                completion(value)
            }
        }, withCancel: { error in
            onError(error.localizedDescription)
            return
        })
    }
    
    func incrementOrDecrementLikesOfPost(withId id: String, completion: @escaping (Post) -> Void, onError: @escaping (String) -> Void) {
        let ref = REF_POSTS.child(id)
        
        ref.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if var post = currentData.value as? [String : AnyObject], let uid = Api.Users.CURRENT_USER?.uid {
                var likes: Dictionary<String, Bool>
                likes = post["likes"] as? [String : Bool] ?? [:]
                var likesCount = post["likesCount"] as? Int ?? 0
                if let _ = likes[uid] {
                    likesCount -= 1
                    likes.removeValue(forKey: uid)
                } else {
                    likesCount += 1
                    likes[uid] = true
                }
                post["likesCount"] = likesCount as AnyObject?
                post["likes"] = likes as AnyObject?
                
                // Set value and report transaction success
                currentData.value = post
                
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                onError(error.localizedDescription)
                return
            }
            if let dict = snapshot?.value as? [String: Any] {
                let post = Post.transformDataToPost(dictionary: dict, key: snapshot!.key)
                completion(post)
            }
        }
    
    }
}
