//
//  ProfileVC.swift
//  SocialApp
//
//  Created by Bold Lion on 30.09.18.
//  Copyright © 2018 Bold Lion. All rights reserved.
//

import UIKit
import SVProgressHUD

class ProfileVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Profile"
    }
    
    @IBAction func logoutTapped(_ sender: UIBarButtonItem) {
        AuthApi.logout(onSuccess: {
            let storyboard = UIStoryboard(name: "Auth", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC")
            self.present(loginVC, animated: true, completion: nil)
        }, onError: { error in
            SVProgressHUD.showError(withStatus: error)
        })
    }
}
