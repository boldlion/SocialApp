//
//  Comment.swift
//  SocialApp
//
//  Created by Bold Lion on 5.10.18.
//  Copyright © 2018 Bold Lion. All rights reserved.
//

struct Comment {
    var id: String?
    var uid: String?
    var text: String?
}


extension Comment {
    
    static func transformDataToComment( dict: [String: Any], key: String) -> Comment {
        var comment = Comment()
        comment.id = key
        comment.text = dict ["text"] as? String
        comment.uid = dict["uid"] as? String
        return comment
    }
}
