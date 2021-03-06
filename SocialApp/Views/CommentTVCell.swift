//
//  CommentTVCell.swift
//  SocialApp
//
//  Created by Bold Lion on 5.10.18.
//  Copyright © 2018 Bold Lion. All rights reserved.
//

import UIKit
import SDWebImage
import KILabel
import SVProgressHUD

protocol CommentTVCellDelegate : AnyObject {
    func goToProfileUser(with id: String)
    func goToProfile()
    func goToHashtag(tag: String)
}

class CommentTVCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var commentLabel: KILabel!
    
    weak var delegateCommentTVCell: CommentTVCellDelegate?

    var comment: Comment? {
        didSet {
            updateView()
        }
    }
    
    var user: UserModel? {
        didSet {
            updateUserInfo()
        }
    }
    
    func updateView() {
        if let commentText = comment?.text {
            commentLabel.userHandleLinkTapHandler = { [unowned self] label, string, range in
                let mention = String(string.dropFirst())
                Api.Users.observeUserByUsername(username: mention.lowercased(), completion: { [unowned self] user in
                    guard let currentUserUid = Api.Users.CURRENT_USER?.uid else { return }
                    if let id = user.id {
                        if id == currentUserUid {
                            self.delegateCommentTVCell?.goToProfile()
                        }
                        else {
                            self.delegateCommentTVCell?.goToProfileUser(with: id)
                        }
                    }
                }, onError: { error in
                    SVProgressHUD.showError(withStatus: error)
                })
            }
            
            commentLabel.hashtagLinkTapHandler = { [unowned self] label, string, range in
                let tag = String(string.dropFirst())
                self.delegateCommentTVCell?.goToHashtag(tag: tag)
            }
            commentLabel.text = commentText
        }
    }
    
    func updateUserInfo() {
        if let name = user?.displayName {
            nameLabel.text = name
        }
        
        if let profileImageString = user?.profileImageString {
            let photoUrl = URL(string: profileImageString)
            profileImageView.sd_setImage(with: photoUrl, placeholderImage: UIImage(named: "profile_placeholder"))
        }
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = UIImage(named: "profile_placeholder")
        nameLabel.text = ""
        commentLabel.text = ""
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addTapGestures()
        initialUI()
    }
    
    func addTapGestures() {
        let tapUsername = UITapGestureRecognizer(target: self, action: #selector(usernameTapped))
        nameLabel.addGestureRecognizer(tapUsername)
        nameLabel.isUserInteractionEnabled = true
        
        let tapProfileImage = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileImageView.addGestureRecognizer(tapProfileImage)
        profileImageView.isUserInteractionEnabled = true
    }
    
    @objc func usernameTapped() {
        guard let currentUserId = Api.Users.CURRENT_USER?.uid else { return }
        if let id = user?.id {
            if id == currentUserId {
                delegateCommentTVCell?.goToProfile()
            }
            else {
                delegateCommentTVCell?.goToProfileUser(with: id)
            }
        }
    }
    
    @objc func profileImageTapped() {
        guard let currentUserId = Api.Users.CURRENT_USER?.uid else { return }
        if let id = user?.id {
            if id == currentUserId {
                delegateCommentTVCell?.goToProfile()
            }
            else {
                delegateCommentTVCell?.goToProfileUser(with: id)
            }
        }
    }

    func initialUI() {
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.clipsToBounds = true
        profileImageView.image = UIImage(named: "profile_placeholder")
        nameLabel.text = ""
        commentLabel.text = ""
    }
}
