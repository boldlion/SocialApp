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
        REF_FOLLOWERS.child(id).child(currentUserUid).setValue(true, withCompletionBlock: { error, databaseRef in
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
                completion()
            })
        })
    }
    
    func unfollowAction(withUser id: String, completion: @escaping () -> Void, onError: @escaping (String) -> Void) {
        guard let currentUserUid = Api.Users.CURRENT_USER?.uid else { return }

        // followers> userId > currentUser : true
        REF_FOLLOWERS.child(id).child(currentUserUid).removeValue(completionBlock: { error, databaseRef in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            // following> currentUser > userId : true
            self.REF_FOLLOWING.child(currentUserUid).child(id).removeValue(completionBlock: { error, databaseRef in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
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
    
}
