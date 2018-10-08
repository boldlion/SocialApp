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
    
    // MARK: SEND POST DATA TO DATABASE
    static func sendPostDataToDatabase(photoImageUrlString: String, caption: String, onSuccess: @escaping () -> Void, onError: @escaping (String) -> Void) {
        guard let userId = Api.Users.CURRENT_USER?.uid else { return }
        let postsRef = Database.database().reference().child(DatabaseLocation.posts)
        let postId = postsRef.childByAutoId().key
        let newPostId = postsRef.child(postId)

        let postDictionary = [ "uid"      : userId,
                               "caption"  : caption,
                               "photoUrl" : photoImageUrlString] 
        
        newPostId.setValue(postDictionary, withCompletionBlock: { error, _ in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            else {
                onSuccess()
            }
        })
    }
    
    // MARK: SEND POST IMAGE TO STORAGE
    static func sendPostImageToStorage(with data: Data, onError: @escaping (String) -> Void, onSuccess: @escaping (String) -> Void) {
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
    
    // MARK: SEND COMMENTS
    static func sendComment(with text: String, postId: String, onError: @escaping (String) -> Void, onSuccess: @escaping () -> Void) {
        let commentRef = Database.database().reference().child(DatabaseLocation.comments)
        let commentId = commentRef.childByAutoId().key
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
                        onSuccess()
                    }
                })
            }
        })
    }
}
