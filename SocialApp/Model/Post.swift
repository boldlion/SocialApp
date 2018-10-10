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
    var likesCount: Int?
    var likes: Dictionary<String, Any>?
    var isLiked: Bool?
}

extension Post {
    
    static func transformDataToPost(dictionary: [String : Any], key: String) -> Post {
        let post = Post()
        post.id = key
        post.uid = dictionary["uid"] as? String
        post.photoUrl = dictionary["photoUrl"] as? String
        post.caption = dictionary["caption"] as? String
        post.likesCount = dictionary["likesCount"] as? Int
        post.likes = dictionary["likes"] as? Dictionary<String, Any>
        
        if let currentUserId = Api.Users.CURRENT_USER?.uid {
            if post.likes != nil {
                post.isLiked = post.likes![currentUserId] != nil
            }
        }

        return post
    }
}
