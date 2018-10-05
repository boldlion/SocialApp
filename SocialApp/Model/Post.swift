//
//  Post.swift
//  SocialApp
//
//  Created by Bold Lion on 3.10.18.
//  Copyright © 2018 Bold Lion. All rights reserved.
//

class Post {
    var id: String?
    var uid: String?
    var photoUrl: String?
    var caption: String?
}

extension Post {
    
    static func transformDataToPost(dictionary: [String : Any], key: String) -> Post {
        let post = Post()
        post.id = key
        post.uid = dictionary["uid"] as? String
        post.photoUrl = dictionary["photoUrl"] as? String
        post.caption = dictionary["caption"] as? String
        return post
    }
}
