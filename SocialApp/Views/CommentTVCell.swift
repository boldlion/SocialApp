//
//  CommentTVCell.swift
//  SocialApp
//
//  Created by Bold Lion on 5.10.18.
//  Copyright © 2018 Bold Lion. All rights reserved.
//

import UIKit
import SDWebImage

class CommentTVCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!

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
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.clipsToBounds = true
        profileImageView.image = UIImage(named: "profile_placeholder")
        nameLabel.text = ""
        commentLabel.text = ""
    }

    
}
