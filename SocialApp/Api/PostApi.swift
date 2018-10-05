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
        })
    }
    
}
