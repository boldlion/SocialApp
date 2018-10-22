//
//  AppDelegate.swift
//  SocialApp
//
//  Created by Bold Lion on 2.10.18.
//  Copyright © 2018 Bold Lion. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window?.tintColor = Colors.tint
        UIBarButtonItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.clear], for: .normal)
        FirebaseApp.configure()
        return true
    }
}

