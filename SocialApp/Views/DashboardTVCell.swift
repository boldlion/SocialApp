//
//  DashboardTVCell.swift
//  SocialApp
//
//  Created by Bold Lion on 3.10.18.
//  Copyright © 2018 Bold Lion. All rights reserved.
//

import UIKit
import SDWebImage

class DashboardTVCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var commentImageView: UIImageView!
    @IBOutlet weak var likeCountButton: UIButton!
    @IBOutlet weak var captionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = UIImage(named: "placeholder")
        postImageView.image = UIImage(named: "profile_placeholder")
        initialUI()
    }
    
    var post: Post? {
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
        if let caption = post?.caption {
            captionLabel.text = caption
        }

        if let image = post?.photoUrl {
            let imageUrl = URL(string: image)
            postImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholder"))
        }
    }
    
    func updateUserInfo() {
        if let name = user?.displayName {
            nameLabel.text = name
        }
        
        if let image = post?.photoUrl { // WRONG IMAGE! Fix it after we add profile Image photo
            let imageUrl = URL(string: image)
            profileImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "profile_placeholder"))
        }
    }
    
    func initialUI() {
        nameLabel.text = ""
        captionLabel.text = ""
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
    }
    
}
