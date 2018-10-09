//
//  Post_CommentsApi.swift
//  SocialApp
//
//  Created by Bold Lion on 9.10.18.
//  Copyright © 2018 Bold Lion. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Post_CommentApi {
    
    let REF_POST_COMMENTS = Database.database().reference().child(DatabaseLocation.post_comments)
    
    func observePostCommentsForPost(withId postId: String, completion: @escaping (String) -> Void, onError: @escaping (String) -> Void) {
        REF_POST_COMMENTS.child(postId).observe(.childAdded, with: { snapshot in
            completion(snapshot.key)
        }, withCancel: { error in
            onError(error.localizedDescription)
            return
        })
    }
}
