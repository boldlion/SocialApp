//
//  Users.swift
//  SocialApp
//
//  Created by Bold Lion on 30.09.18.
//  Copyright © 2018 Bold Lion. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class UsersApi {
    
    let REF_USERS = Database.database().reference().child("users")
    
    func fetchUser(withId id: String,completion: @escaping (UserModel) -> Void, onError: @escaping (String) -> Void) {
        REF_USERS.child(id).observeSingleEvent(of: .value, with: { snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let user = UserModel.transformDataToUser(dictionary: dict, key: snapshot.key)
                completion(user)
            }
        }, withCancel: { error in
            onError(error.localizedDescription)
        })
    }
    
    
    // MARK: - Get Current Logged User
    var CURRENT_USER: User? {
        if let currentUser = Auth.auth().currentUser {
            return currentUser
        }
        else {
            return nil
        }
    }
    
}
