//
//  AuthApi.swift
//  SocialApp
//
//  Created by Bold Lion on 30.09.18.
//  Copyright © 2018 Bold Lion. All rights reserved.
//
import Foundation
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class AuthApi {
    // MARK: - LOGIN USER
    static func loginWith(email: String, password: String, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password, completion:  { user, error in
            if error != nil  {
                onError(error!.localizedDescription)
                return
            }
            onSuccess()
        })
    }
    
    // MARK: - REGISTER NEW USER
    static func registerWith(data: Data, displayName: String, username: String, email: String, password: String, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void)  {
        Auth.auth().createUser(withEmail: email, password: password, completion: { user, error in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            if let uid = Auth.auth().currentUser?.uid {
                self.setUserInformation(data: data,
                                        displayName: displayName,
                                        username: username,
                                        email: email,
                                        uid: uid,
                                        onSuccess: onSuccess,
                                        onError: onError)
            }
        })
    }
    
    // MARK: - Set new user account data
    static func setUserInformation(data: Data, displayName: String, username: String, email: String, uid: String, onSuccess: @escaping () -> Void, onError: @escaping (String) -> Void) {
        
        DatabaseService.sendProfileImageToStorage(with: data, onError: { errorMessage in
            onError(errorMessage)
            return
        }, onSuccess: { profileImageUrlString in
            Api.Users.REF_USERS.child(uid).setValue([
                "displayName"        : displayName,
                "username"           : username,
                "username_lowercase" : username.lowercased(),
                "email"              : email,
                "profileImageUrl"    : profileImageUrlString
                ])
            onSuccess()
        })
        

    }
    
    
    // MARK: Reset User Password
    static func resetPassword(withEmail: String, onSuccess: @escaping () -> Void,  onError: @escaping (_ errorMessage: String?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: withEmail) {
            error in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            onSuccess()
        }
    }
    
    // MARK: Update User Info
    
    //    static func updateUserInformation(username: String, email: String, imageData: Data, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void)
    //    {
    //
    //        // TODO: It throws and error, it requires to re-authenticate the user, so it doesnt change the auth email, it saves the data and all, but doesn't update the auth email
    //        // Step 1. If Users email has been changed, we need to change the authentication email!
    //        Api.User.CURRENT_USER?.updateEmail(to: email, completion: { (error) in
    //            if error != nil
    //            {
    //                onError(error?.localizedDescription)
    //                return
    //            }
    //            else
    //            {
    //                // Step 2. Upload image to storage, get the downloaded image URL and set the new updated values (ONLY) to database
    //                let uid = Api.User.CURRENT_USER?.uid
    //                let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOF_REF).child("profile_image").child(uid!)
    //
    //                storageRef.putData(imageData, metadata: nil, completion:
    //                    { (metadata, error) in
    //                        if error != nil
    //                        {
    //                            onError(error?.localizedDescription)
    //                            return
    //                        }
    //                        let profileImageURL = metadata?.downloadURL()?.absoluteString
    //
    //                        self.updateDatabase(profileImageULR: profileImageURL!, username: username, email: email, onSuccess: onSuccess, onError:onError )
    //                })
    //            }
    //        })
    //    }
    
    //    static func updateDatabase(profileImageULR: String, username: String, email: String, onSuccess: @escaping () -> Void,onError: @escaping (_ errorMessage: String?) -> Void)
    //    {
    //        let dictionary = [ "profileImageURL": profileImageULR,
    //                           "username" : username,
    //                           "username_lowercase" : username.lowercased(), // lowercase for searching purposes only!
    //            "email"    : email
    //        ]
    //        Api.User.REF_CURRENT_USER?.updateChildValues(dictionary, withCompletionBlock: { (error, ref) in
    //            if error != nil
    //            {
    //                onError(error!.localizedDescription)
    //
    //            }
    //            else
    //            {
    //                onSuccess()
    //            }
    //        })
    //    }
    
    // MARK: Log out
    static func logout(onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        do {
            try Auth.auth().signOut()
            onSuccess()
        }
        catch let logoutError {
            onError(logoutError.localizedDescription)
            return
        }
    }
}

