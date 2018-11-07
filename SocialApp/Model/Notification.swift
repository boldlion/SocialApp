//
//  Notification.swift
//  SocialApp
//
//  Created by Bold Lion on 6.11.18.
//  Copyright © 2018 Bold Lion. All rights reserved.
//

import Foundation

class NotificationC {
    
    var id: String?
    var from: String?
    var objectId: String?
    var type: String?
    var timestamp: Int?
}

extension NotificationC {
    
    static func transformDataToNotification(dict: [String: Any], key: String) -> NotificationC {
        
        let notification = NotificationC()
        
        notification.id = key
        notification.from = dict["from"] as? String
        notification.objectId = dict["objectId"] as? String
        notification.type = dict["type"] as? String
        notification.timestamp = dict["timestamp"] as? Int
        
        return notification
    }
}
