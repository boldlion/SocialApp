//
//  HeaderProfileCollectionReusableView.swift
//  SocialApp
//
//  Created by Bold Lion on 10.10.18.
//  Copyright © 2018 Bold Lion. All rights reserved.
//

import UIKit
import SVProgressHUD
import SDWebImage

class HeaderProfileCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var myPostCountLabel: UILabel!
    @IBOutlet weak var follwingCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    
    @IBOutlet weak var editProfileButton: UIButton!
    
    var user: UserModel? {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        if let name = user?.displayName {
            nameLabel.text = name
        }
        if let imageString = user?.profileImageString { // WRONG IMAGE! Fix it after we add profile Image photo
            let imageUrl = URL(string: imageString)
            self.profileImage.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "profile_placeholder"))
        }
    }
}
