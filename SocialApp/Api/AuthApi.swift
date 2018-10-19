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
    
    // MARK:- REGISTER NEW USER
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
    
    
    // MARK:- Reset User Password
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
    static func updateUserInformation(email: String, displayName: String, imageData: Data, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        guard let uid = Api.Users.CURRENT_USER?.uid else { return }
        
        Api.Users.CURRENT_USER?.updateEmail(to: email, completion: { error in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            else {
                let storageRef = Storage.storage().reference().child("profile_photos").child(uid)
                
                storageRef.putData(imageData, metadata: nil, completion: { metadata, error in
                    if error != nil {
                        onError(error!.localizedDescription)
                        return
                    }
                    storageRef.downloadURL(completion: { url, error in
                        guard let downloadUrl = url else { return }
                        let profileImageUrlString = downloadUrl.absoluteString
                        self.updateDatabase(profileImageULR: profileImageUrlString, email: email, displayName: displayName, onSuccess: onSuccess, onError:onError )
                    })
                })
            }
        })
    }
    
    static func updateDatabase(profileImageULR: String, email: String, displayName: String, onSuccess: @escaping () -> Void,onError: @escaping (_ errorMessage: String?) -> Void) {
        let dictionary = [ "profileImageUrl": profileImageULR,
                           "displayName": displayName,
                           "email" : email ]

        Api.Users.REF_CURRENT_USER?.updateChildValues(dictionary, withCompletionBlock: { (error, ref) in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            else {
                onSuccess()
            }
        })
    }
    
    
    // MARK: Logout
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

