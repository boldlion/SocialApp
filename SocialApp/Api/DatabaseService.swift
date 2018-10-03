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
            }
            else {
                onSuccess()
            }
        })
    }
    
    
    static func sendPostImageToStorage(with data: Data, onError: @escaping (String) -> Void, onSuccess: @escaping (String) -> Void) {
        let phototIdString = UUID().uuidString
        
        let storagePostRef = Storage.storage().reference().child(StorageLocation.Posts).child(phototIdString)
        
        storagePostRef.putData(data, metadata: nil, completion: { metadata, error in
            
            if error != nil {
                onError(error!.localizedDescription)
            }
            storagePostRef.downloadURL(completion: { url, urlError in
                guard let downloadUrl = url else { return }
                
                let postImageUrl = downloadUrl.absoluteString
                onSuccess(postImageUrl)
            })
        })
    }
}
