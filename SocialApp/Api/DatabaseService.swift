//
//  DatabaseService.swift
//  SocialApp
//
//  Created by Bold Lion on 2.10.18.
//  Copyright © 2018 Bold Lion. All rights reserved.
//
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

class DatabaseService {
    
    // MARK: - Upload Data To Server
    static func uploadDataToServer(data: Data, videoUrl: URL? = nil, ratio: CGFloat, caption: String, onSuccess: @escaping () -> Void, onError: @escaping (String) -> Void) {
        
        //***************** VIDEO SHARING CASE ******************//
        if let videoUrl = videoUrl {
            // 1. Upload Video To Firebase Storage
            uploadVideoToFirebaseStorate(videoUrl: videoUrl, onSuccess: { videoUrlString in
                // 2. Upload Video Thumbnail To Firebase Storage
                uploadImageToStorage(with: data, onSuccess: { videoThumbnail in
                    // 3. Send Post Data to Firebase Database
                    sendPostDataToDatabase(photoImageUrlString: videoThumbnail, videoUrl: videoUrlString, ratio: ratio,  caption: caption, onSuccess: onSuccess, onError: onError)
                }, onError: onError)
            }, onError: onError)
        }
        //***************** PHOTO SHARING CASE ******************//
        else {
            // 1. Upload Photo to Firebase Storage
            uploadImageToStorage(with: data, onSuccess: { photoUrlString in
                // 2. Send Post Data to Firebase Database
                sendPostDataToDatabase(photoImageUrlString: photoUrlString, ratio: ratio, caption: caption, onSuccess: onSuccess, onError: onError)
            }, onError: onError)
        }
    }

    // MARK: - SEND POST IMAGE TO FIREBASE STORAGE
    static func uploadImageToStorage(with data: Data, onSuccess: @escaping (String) -> Void, onError: @escaping (String) -> Void) {
        let phototIdString = UUID().uuidString
        let storagePostRef = Storage.storage().reference().child(StorageLocation.Posts).child(phototIdString)
        storagePostRef.putData(data, metadata: nil, completion: { metadata, error in
            
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            storagePostRef.downloadURL(completion: { url, urlError in
                guard let downloadUrl = url else { return }
                
                let postImageUrl = downloadUrl.absoluteString
                onSuccess(postImageUrl)
            })
        })
    }
    
    // MARK: - UPLOAD VIDEO TO FIREBASE STORAGE
    static func uploadVideoToFirebaseStorate(videoUrl: URL, onSuccess: @escaping (String) -> Void, onError: @escaping (String) -> Void) {
        let videoIdString = UUID().uuidString
        let storagePostRef = Storage.storage().reference().child(StorageLocation.Posts).child(videoIdString)
        storagePostRef.putFile(from: videoUrl, metadata: nil, completion: { metadata, error in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            storagePostRef.downloadURL(completion: { url, urlError in
                guard let downloadUrl = url else { return }
                
                let videoUrlString = downloadUrl.absoluteString
                onSuccess(videoUrlString)
            })
        })
    }
    
    // MARK: - SEND POST DATA TO DATABASE
    static func sendPostDataToDatabase(photoImageUrlString: String, videoUrl: String? = nil, ratio: CGFloat, caption: String, onSuccess: @escaping () -> Void, onError: @escaping (String) -> Void) {
        guard let userId = Api.Users.CURRENT_USER?.uid else { return }
        let postsRef = Database.database().reference().child(DatabaseLocation.posts)
        guard let postId = postsRef.childByAutoId().key else { return }
        let newPostId = postsRef.child(postId)
        
        // **** HASHTAG FEATURE **** //
        
        let words = caption.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        for var word in words {
            if word.hasPrefix("#") {
                word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                let newHastTagRef = Api.Hashtag.REF_HASHTAG.child(word.lowercased())
                newHastTagRef.updateChildValues([postId: true])
            }
        }
        
        // *** Timestamp *** //
        let timestamp = Int(Date().timeIntervalSince1970)
        
        var postDictionary = [ "uid"       : userId,
                               "caption"   : caption,
                               "photoUrl"  : photoImageUrlString,
                               "photoRatio": ratio,
                               "likesCount": 0,
                               "timestamp" : timestamp ] as [String : Any]
        
        if let videoUrl = videoUrl {
            postDictionary["videoUrl"] = videoUrl
        }
        
        // posts > postId > postdata
        newPostId.setValue(postDictionary, withCompletionBlock: { error, _ in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            else {
                // user_posts > userId > postId
                let refUserposts = Api.User_Posts.REF_USER_POSTS.child(userId).child(postId)
                refUserposts.setValue(["timestamp": timestamp], withCompletionBlock: { errorUserPosts, dbRef in
                    if errorUserPosts != nil {
                        onError(errorUserPosts!.localizedDescription)
                        return
                    }
                    // feed > currentUserId > postId > timestamp
                    Api.Feed.REF_FEED.child(userId).child(postId).setValue(["timestamp": timestamp])
                    
                    // update the feed for each of the followers of the current user
                    Api.Follow.REF_FOLLOWERS.child(userId).observeSingleEvent(of: .value, with: { snapshot in
                        let arraySnapshot = snapshot.children.allObjects as! [DataSnapshot]
                        arraySnapshot.forEach({ child in
                            Api.Feed.REF_FEED.child(child.key).child(postId).setValue(["timestamp" : timestamp])
                            
                            // notification > userId > feed
                            guard let newNotifcationId = Api.Notification.REF_NOTIFICATION.child(child.key).childByAutoId().key else { return }
                            let newNotifcationReference = Api.Notification.REF_NOTIFICATION.child(child.key).child(newNotifcationId)
                            
                            newNotifcationReference.setValue(["from" : userId,
                                                              "type" : "feed",
                                                              "objectId" : postId,
                                                              "timestamp": timestamp
                                                            ])
                        })
                    })
                    onSuccess()
                })
            }
        })
    }
    
    
    // MARK: - SEND COMMENTS
    static func sendComment(with text: String, postId: String, onError: @escaping (String) -> Void, onSuccess: @escaping () -> Void) {
        let commentRef = Database.database().reference().child(DatabaseLocation.comments)
        guard let commentId = commentRef.childByAutoId().key else { return }
        let newCommentRef = commentRef.child(commentId)
        
        guard let userUid = Api.Users.CURRENT_USER?.uid else { return }
        
        let dict = [ "text" : text,
                     "uid": userUid ]
        
        newCommentRef.setValue(dict, withCompletionBlock: { error, _ in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            else {
                // post_comments > commentId : true
                let postCommentRef = Database.database().reference().child("post_comments").child(postId).child(commentId)
                postCommentRef.setValue(true, withCompletionBlock: { error, dbRef in
                    if error != nil {
                        onError(error!.localizedDescription)
                        return
                    }
                    else {
                        
                        // **** COMMENTS HASHTAGS **** //
                        let words = text.components(separatedBy: CharacterSet.whitespacesAndNewlines)
                        for var word in words {
                            if word.hasPrefix("#") {
                                word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                                let newHastTagRef = Api.Hashtag.REF_HASHTAG.child(word.lowercased())
                                newHastTagRef.updateChildValues([postId: true])
                            }
                        }
                        onSuccess()
                    }
                })
            }
        })
    }
    
    // MARK: - SEND PROFILE IMAGE TO STORAGE
    static func sendProfileImageToStorage(with data: Data, onError: @escaping (String) -> Void, onSuccess: @escaping (_ profileImageString: String) -> Void) {
        let phototIdString = UUID().uuidString
        
        let storagePostRef = Storage.storage().reference().child(StorageLocation.Profile_Photos).child(phototIdString)
        
        storagePostRef.putData(data, metadata: nil, completion: { metadata, error in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            storagePostRef.downloadURL(completion: { url, urlError in
                guard let downloadUrl = url else { return }
                
                let postImageUrl = downloadUrl.absoluteString
                onSuccess(postImageUrl)
            })
        })
    }
    
}
