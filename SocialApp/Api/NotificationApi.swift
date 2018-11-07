//
//  NotificationApi.swift
//  SocialApp
//
//  Created by Bold Lion on 6.11.18.
//  Copyright © 2018 Bold Lion. All rights reserved.
//

import Foundation
import FirebaseDatabase

class NotificationApi {
    
    let REF_NOTIFICATION = Database.database().reference().child(DatabaseLocation.notification)
    
    func observeNotifications(completion: @escaping (NotificationC) -> Void, onError: @escaping (String) -> Void) {
        guard let id = Api.Users.CURRENT_USER?.uid else { return }
        REF_NOTIFICATION.child(id).observe(.childAdded, with: { snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let notification = NotificationC.transformDataToNotification(dict: dict, key: snapshot.key)
                completion(notification)
            }
        }, withCancel: { error in
            onError(error.localizedDescription)
            return
        })
    }
}
