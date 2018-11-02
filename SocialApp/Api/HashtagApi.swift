//
//  HashtagApi.swift
//  SocialApp
//
//  Created by Bold Lion on 30.10.18.
//  Copyright © 2018 Bold Lion. All rights reserved.
//

import Foundation
import FirebaseDatabase

class HashtagApi {
    
    let REF_HASHTAG = Database.database().reference().child(DatabaseLocation.hashtag)
    
    func fetchPostsForTag(withTag tag: String, completion: @escaping (String) -> Void) {
        REF_HASHTAG.child(tag.lowercased()).observe(.childAdded, with: { snapshot in
            completion(snapshot.key)
        })
    }
}
