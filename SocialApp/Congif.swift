//
//  Config.swift
//  SocialApp
//
//  Created by Bold Lion on 2.10.18.
//  Copyright © 2018 Bold Lion. All rights reserved.
//
import FirebaseStorage
import FirebaseDatabase

struct StorageLocation {
    static let Root_Ref = Storage.storage().reference()
    static let Profile_Photos = "profile_photos"
    static let Posts = "posts"
}

struct DatabaseLocation {
    static let posts = "posts"
}
