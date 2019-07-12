//
//  DiscoverTVCell.swift
//  SocialApp
//
//  Created by Bold Lion on 12.10.18.
//  Copyright © 2018 Bold Lion. All rights reserved.
//

import UIKit
import SDWebImage
import SVProgressHUD

protocol DiscoverTVCellDelegate : AnyObject {
    func goToUserProfile(withId id: String)
}

class DiscoverTVCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    weak var delegateShowUserProfile: DiscoverTVCellDelegate?

    var user: UserModel? {
        didSet {
            updateView()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addTapGestures()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImage.image = UIImage(named: "placeholder")
        usernameLabel.text = " "
    }
    
    func updateView() {
        if let imageString = user?.profileImageString {
            let url = URL(string: imageString)
            profileImage.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
        }
        if let name = user?.displayName {
            usernameLabel.text = name
        }
        if let isFollowing = user?.isFollowing {
            isFollowing ? configureUnfollowButton() : configureFollowButton()
        }
    }
    
    @objc func followAction() {
        guard let userId = user?.id else { return }
        if user!.isFollowing == false {

            Api.Follow.followAction(withUser: userId, completion: { [unowned self] in
                self.followButton.isHidden = false
                self.configureUnfollowButton()
                self.user!.isFollowing = true
            }, onError: { error in
                SVProgressHUD.showError(withStatus: error)
            })
        }
    }
    
    @objc func unfollowAction() {
        guard let userId = user?.id else { return }
        
        if user!.isFollowing! == true {
            Api.Follow.unfollowAction(withUser: userId, completion: { [unowned self] in
                self.followButton.isHidden = false
                self.configureFollowButton()
                self.user!.isFollowing = false
            }, onError: { error in
                SVProgressHUD.showError(withStatus: error)
            })
        }
    }
    
    func configureFollowButton() {
        guard let currentUserID = Api.Users.CURRENT_USER?.uid else { return }
        guard let userId = user?.id else { return }
        if currentUserID == userId {
            followButton.isHidden = true
        }
        else {
            followButton.setTitle("follow", for: .normal)
            followButton.addTarget(self, action: #selector(followAction), for: .touchUpInside)
            followButton.backgroundColor = Colors.tint
            followButton.setTitleColor(.white, for: .normal)
            followButton.layer.cornerRadius = 5
            followButton.layer.borderColor = Colors.tint.cgColor
        }
    }
    
    func configureUnfollowButton() {
        followButton.setTitle("following", for: .normal)
        followButton.addTarget(self, action: #selector(unfollowAction), for: .touchUpInside)
        followButton.backgroundColor = .clear
        followButton.setTitleColor(.lightGray, for: .normal)
        followButton.layer.borderColor = UIColor.lightGray.cgColor
        followButton.layer.borderWidth = 1
        followButton.layer.cornerRadius = 5
    }
    
    func addTapGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(usernameTapped))
        usernameLabel.isUserInteractionEnabled = true
        usernameLabel.addGestureRecognizer(tap)
        
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(imageTap)
    }
    
    @objc func usernameTapped() {
        if let uid = user?.id {
            delegateShowUserProfile?.goToUserProfile(withId: uid)
        }
    }
    
    @objc func profileImageTapped() {
        if let uid = user?.id {
           delegateShowUserProfile?.goToUserProfile(withId: uid)
        }
    }
}
