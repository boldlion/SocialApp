//
//  Api.swift
//  SocialApp
//
//  Created by Bold Lion on 30.09.18.
//  Copyright © 2018 Bold Lion. All rights reserved.
//

import Foundation

struct Api {
    static var Users = UsersApi()
    static var Auth  = AuthApi()
    static var Post = PostApi()
    static var User_Posts = UserPostsApi()
    static var Comment = CommentApi()
    static var Post_Comment = Post_CommentApi()
    static var Follow = FollowApi()
    static var Feed = FeedApi()
    static var Hashtag = HashtagApi()
    static var Notification = NotificationApi()
}
