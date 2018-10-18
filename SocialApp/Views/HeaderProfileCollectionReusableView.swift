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

protocol HeaderProfileCollectionReusableViewDelegate {
    func updateFollowButton(forUser user: UserModel)
}

class HeaderProfileCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var myPostCountLabel: UILabel!
    @IBOutlet weak var follwingCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    
    @IBOutlet weak var editProfileButton: UIButton!
    
    var delegate: HeaderProfileCollectionReusableViewDelegate?
    
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
        
        if user?.id == Api.Users.CURRENT_USER?.uid {
            editProfileButton.setTitle("Edit Profile", for: .normal)
        }
        else {
            updateFollowButtonState()
        }
    }
    
    func updateFollowButtonState() {
        if let isFollowing = user?.isFollowing {
            isFollowing ? configureUnfollowButton() : configureFollowButton()
        }
    }
    
    func configureFollowButton() {
        editProfileButton.setTitle("follow", for: .normal)
        editProfileButton.addTarget(self, action: #selector(followAction), for: .touchUpInside)
        editProfileButton.backgroundColor = Colors.tint
        editProfileButton.setTitleColor(.white, for: .normal)
        editProfileButton.layer.cornerRadius = 5
        editProfileButton.layer.borderColor = Colors.tint.cgColor
    }
    
    func configureUnfollowButton() {
        editProfileButton.setTitle("following", for: .normal)
        editProfileButton.addTarget(self, action: #selector(unfollowAction), for: .touchUpInside)
        editProfileButton.backgroundColor = .clear
        editProfileButton.setTitleColor(.lightGray, for: .normal)
        editProfileButton.layer.borderColor = UIColor.lightGray.cgColor
        editProfileButton.layer.borderWidth = 1
        editProfileButton.layer.cornerRadius = 5
    }
    
    @objc func followAction() {
        guard let userId = user?.id else { return }
        
        if user!.isFollowing == false {
            Api.Follow.followAction(withUser: userId, completion: {
                self.configureUnfollowButton()
                self.user!.isFollowing = true
                self.delegate?.updateFollowButton(forUser: self.user!)
            }, onError: { error in
                SVProgressHUD.showError(withStatus: error)
            })
        }
    }
    
    @objc func unfollowAction() {
        guard let userId = user?.id else { return }
        
        if user!.isFollowing! == true {
            Api.Follow.unfollowAction(withUser: userId, completion: {
                self.configureFollowButton()
                self.user!.isFollowing = false
                self.delegate?.updateFollowButton(forUser: self.user!)
            }, onError: { error in
                SVProgressHUD.showError(withStatus: error)
            })
        }
    }
}
