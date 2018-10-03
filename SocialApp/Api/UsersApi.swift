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
