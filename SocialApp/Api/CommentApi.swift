//
//  CommentApi.swift
//  SocialApp
//
//  Created by Bold Lion on 7.10.18.
//  Copyright © 2018 Bold Lion. All rights reserved.
//
import FirebaseDatabase

class CommentApi {
    
    let REF_COMMENTS = Database.database().reference().child(DatabaseLocation.comments)
    
    func observeCommentsForPost(withId commentId: String, completion: @escaping (Comment) -> Void, onError: @escaping (String) -> Void) {
        REF_COMMENTS.child(commentId).observeSingleEvent(of: .value, with: { snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let comment = Comment.transformDataToComment(dict: dict, key: snapshot.key)
                completion(comment)
            }
        }, withCancel: { error in
            onError(error.localizedDescription)
            return
        })
    }
    
}
