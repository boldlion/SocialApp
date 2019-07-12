//
//  FollowApi.swift
//  SocialApp
//
//  Created by Bold Lion on 12.10.18.
//  Copyright © 2018 Bold Lion. All rights reserved.
//

import FirebaseDatabase

class FollowApi {
    
    let REF_FOLLOWERS = Database.database().reference().child(DatabaseLocation.followers)
    let REF_FOLLOWING = Database.database().reference().child(DatabaseLocation.following)

    func followAction(withUser id: String, completion: @escaping () -> Void, onError: @escaping (String) -> Void) {
        guard let currentUserUid = Api.Users.CURRENT_USER?.uid else { return }
        
        // followers > userId > currentUser : true
        REF_FOLLOWERS.child(id).child(currentUserUid).setValue(true, withCompletionBlock: { [unowned self] error, databaseRef in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            // following > currentUser > userId : true
            self.REF_FOLLOWING.child(currentUserUid).child(id).setValue(true, withCompletionBlock: { error, databaseRef in
                if error != nil {
                    onError(error!.localizedDescription)
                    return
                }
                
                // feed > currentUser >
                Api.User_Posts.REF_USER_POSTS.child(id).observeSingleEvent(of: .value, with: { snapshot in
                    if let dict = snapshot.value as? [String : Any] {
                        for key in dict.keys {
                            if let value = dict[key] as? [String : Any] {
                                if let timestampPost = value["timestamp"] as? Int {
                                    Api.Feed.REF_FEED.child(currentUserUid).child(key).setValue(["timestamp": timestampPost])

                                }
                            }
                        }
                    }
                })
                completion()
            })
        })
    }
    
    func unfollowAction(withUser id: String, completion: @escaping () -> Void, onError: @escaping (String) -> Void) {
        guard let currentUserUid = Api.Users.CURRENT_USER?.uid else { return }

        // followers> userId > currentUser : true (remove)
        REF_FOLLOWERS.child(id).child(currentUserUid).removeValue(completionBlock: { [unowned self] error, databaseRef in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            // following> currentUser > userId : true (remove)
            self.REF_FOLLOWING.child(currentUserUid).child(id).removeValue(completionBlock: { error, databaseRef in
                if error != nil {
                    onError(error!.localizedDescription)
                    return
                }
                // feed > currentUser > postId (remove)
                Api.User_Posts.REF_USER_POSTS.child(id).observeSingleEvent(of: .value, with: { snapshot in
                    if let dict = snapshot.value as? [String : Any] {
                        for key in dict.keys {
                            Api.Feed.REF_FEED.child(currentUserUid).child(key).removeValue()
                        }
                    }
                })
                completion()
            })
        })
    }
    
    func isFollowing(userId: String, completion: @escaping (Bool) -> Void, onError: @escaping (String) -> Void ) {
        guard let currentUserUid = Api.Users.CURRENT_USER?.uid else { return }
        REF_FOLLOWERS.child(userId).child(currentUserUid).observeSingleEvent(of: .value, with: { snapshot in
            if let _ = snapshot.value as? NSNull {
                // not in the followers list of the current user
                completion(false)
            }
            else {
                completion(true)
            }
        }, withCancel: { error in
            onError(error.localizedDescription)
            return
        })
    }
    
    
    func fetchFollowersCount(forUserId id: String, completion: @escaping (Int) -> Void) {
        REF_FOLLOWERS.child(id).observe(.value, with: { snapshot in
            let count = Int(snapshot.childrenCount)
            completion(count)
        })
    }
    
    func fetchFollowingCount(forUserId id: String, completion: @escaping (Int) -> Void) {
        REF_FOLLOWING.child(id).observe(.value, with: { snapshot in
            let count = Int(snapshot.childrenCount)
            completion(count)
        }) 
    }
    
    func fetchFollowers(forUserId id: String, completion: @escaping (String) -> Void) {
        REF_FOLLOWERS.child(id).observeSingleEvent(of: .value, with: { snapshot in
            if let dict = snapshot.value as? [String : Any] {
                for (userId, _) in dict {
                    completion(userId)
                }
            }
        })
    }
    
    
    func fetchFollowing(forUserId id: String, completion: @escaping (String) -> Void) {
        REF_FOLLOWERS.child(id).observeSingleEvent(of: .value, with: { snapshot in
            if let dict = snapshot.value as? [String : Any] {
                for (userId, _) in dict {
                    completion(userId)
                }
            }
        })
    }
}
