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

protocol HeaderProfileShowFollowersAndFollowingDelegate {
    func showFollowersForUser(withId id: String)
    func showFollowingForUser(withId id: String)
}

protocol HeaderProfileCollectionReusableViewDelegateSwitchToSettingTVC {
    func goToSettingVC()
}

class HeaderProfileCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var myPostCountLabel: UILabel!
    @IBOutlet weak var follwingCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    
    @IBOutlet weak var editProfileButton: UIButton!
    
    var delegate: HeaderProfileCollectionReusableViewDelegate?
    var delegateSettings: HeaderProfileCollectionReusableViewDelegateSwitchToSettingTVC?
    var delegateShowFollowersAndFollowing: HeaderProfileShowFollowersAndFollowingDelegate?
    
    var user: UserModel? {
        didSet {
            updateView()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        clear()
        addTapGestures()
    }
    
    func updateView() {
        guard let userId = user?.id else { return }
        
        if let name = user?.displayName {
            nameLabel.text = name
        }
        if let imageString = user?.profileImageString {
            let imageUrl = URL(string: imageString)
            self.profileImage.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "profile_placeholder"))
        }
        
        Api.User_Posts.fetchUserPostsCount(forUserId: userId, completion: { count in
            self.myPostCountLabel.text = String(count)
        })
        
        Api.Follow.fetchFollowersCount(forUserId: userId, completion: { count in
            self.followersCountLabel.text = String(count)
        })
        
        Api.Follow.fetchFollowingCount(forUserId: userId, completion: { count in
            self.follwingCountLabel.text = String(count)
        })
        
        if user?.id == Api.Users.CURRENT_USER?.uid {
            editProfileButton.setTitle("Edit Profile", for: .normal)
            editProfileButton.addTarget(self, action: #selector(goToSettingTVC), for: .touchUpInside)
        }
        else {
            updateFollowButtonState()
        }
    }
    
    @objc func goToSettingTVC() {
        delegateSettings?.goToSettingVC()
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
    
    func addTapGestures() {
        let followersCountTap = UITapGestureRecognizer(target: self, action: #selector(followersTapped))
        followersCountLabel.isUserInteractionEnabled = true
        followersCountLabel.addGestureRecognizer(followersCountTap)
        
        let followersLabelTapepd = UITapGestureRecognizer(target: self, action: #selector(followersTapped))
        followersLabel.isUserInteractionEnabled = true
        followersLabel.addGestureRecognizer(followersLabelTapepd)
        
        let followingLabelTapepd = UITapGestureRecognizer(target: self, action: #selector(followingTapped))
        followingLabel.isUserInteractionEnabled = true
        followingLabel.addGestureRecognizer(followingLabelTapepd)
        
        let followersCountTapepd = UITapGestureRecognizer(target: self, action: #selector(followingTapped))
        follwingCountLabel.isUserInteractionEnabled = true
        follwingCountLabel.addGestureRecognizer(followersCountTapepd)
    }
    
    @objc func followersTapped() {
        if let id = user?.id {
            delegateShowFollowersAndFollowing?.showFollowersForUser(withId: id)
        }
    }
    
    @objc func followingTapped() {
        if let id = user?.id {
            delegateShowFollowersAndFollowing?.showFollowingForUser(withId: id)
        }
    }
    
    func clear() {
        myPostCountLabel.text = ""
        followersCountLabel.text = ""
        follwingCountLabel.text = ""
    }
}
