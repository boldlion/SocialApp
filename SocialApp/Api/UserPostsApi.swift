//
//  UserPostsApi.swift
//  SocialApp
//
//  Created by Bold Lion on 11.10.18.
//  Copyright © 2018 Bold Lion. All rights reserved.
//

import FirebaseDatabase

class UserPostsApi {
    
    let REF_USER_POSTS = Database.database().reference().child(DatabaseLocation.user_posts)
    
    func observeUserPosts(completion: @escaping (String) -> Void, onError: @escaping (String) -> Void) {
        guard let currentUser = Api.Users.CURRENT_USER else { return }
        
        REF_USER_POSTS.child(currentUser.uid).observe(.childAdded, with: { snapshot in
            completion(snapshot.key)
        }, withCancel: { error in
            onError(error.localizedDescription)
            return
        })
    }
    
}
