//
//  FeedApi.swift
//  SocialApp
//
//  Created by Bold Lion on 14.10.18.
//  Copyright © 2018 Bold Lion. All rights reserved.
//

import FirebaseDatabase

class FeedApi {
    let REF_FEED = Database.database().reference().child(DatabaseLocation.feed)
    
    func observeFeedPosts(completion: @escaping (Post) -> Void, onError: @escaping (String) -> Void) {
        guard let id = Api.Users.CURRENT_USER?.uid else { return }
        REF_FEED.child(id).queryOrdered(byChild: "timestamp").observe(.childAdded, with: { snapshot in
            let key = snapshot.key
            Api.Post.observePostSingleEvent(withId: key, completion: { post in
                completion(post)
            }, onError: { errorPost in
                onError(errorPost)
                return
            })
        }, withCancel: { error in
            onError(error.localizedDescription)
            return
        })
    }
    
    func observeFeedRemoved(completion: @escaping (Post) -> Void, onError: @escaping (String) -> Void) {
        guard let id = Api.Users.CURRENT_USER?.uid else { return }

        REF_FEED.child(id).observe(.childRemoved, with: { snapshot in
            let key = snapshot.key
            Api.Post.observePostSingleEvent(withId: key, completion: { post in
                completion(post)
            }, onError: { errorPost in
                onError(errorPost)
                return
            })
        }, withCancel: { error in
            onError(error.localizedDescription)
            return
        })
    }
    
}
