//
//  ActivityTVCell.swift
//  SocialApp
//
//  Created by Bold Lion on 6.11.18.
//  Copyright © 2018 Bold Lion. All rights reserved.
//

import UIKit
import SDWebImage
import SVProgressHUD

protocol ActivityTVCellDelegate {
    func goToDetailVC(withPostId id: String)
}

class ActivityTVCell: UITableViewCell {

    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var postPhoto: UIImageView!
    
    var delegate: ActivityTVCellDelegate?
    
    var user: UserModel? {
        didSet {
            setupUserInfo()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addTapGesture()
    }

    
    var notification: NotificationC? {
        didSet {
            updateView()
        }
    }
    
    func setupUserInfo() {
        if let photoString = user?.profileImageString {
            let url = URL(string: photoString)
            profileImage.sd_setImage(with: url, placeholderImage: UIImage(named: "profile_placeholder"))
        }
        
        if let username = user?.username {
            usernameLabel.text = username
        }
    }
    
    func updateView() {
        if let type = notification?.type {
            switch type {
            case "feed":
                descriptionLabel.text = "shared a new post"
                if let postId = notification?.objectId {
                    Api.Post.observePostSingleEvent(withId: postId, completion: { post in
                        guard let postImagString = post.photoUrl, let url = URL(string: postImagString) else { return }
                        self.postPhoto.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
                    }, onError: { error in
                        SVProgressHUD.showError(withStatus: error)
                    })
                }
            default:
                print("default")
            }
        }
        
        if let timestamp = notification?.timestamp {
            let timestampDate = Date(timeIntervalSince1970: Double(timestamp))
            let now = Date()
            let components = Set<Calendar.Component>([.second, .minute, .hour, .day, .weekOfMonth])
            let difference = Calendar.current.dateComponents(components, from: timestampDate, to: now)
            
            var timestampText = ""
            if difference.second! <= 0 {
                timestampText = "1 sec"
            }
            if difference.second! > 0 && difference.minute! == 0 {
                timestampText = "\(difference.second!)s"
            }
            if difference.minute! > 0 && difference.hour! == 0 {
                timestampText = "\(difference.minute!)m"
            }
            if difference.hour! > 0 && difference.day! == 0 {
                timestampText = "\(difference.hour!)h"
            }
            if difference.day! > 0 && difference.weekOfMonth! == 0 {
                timestampText = "\(difference.day!)d"
            }
            if difference.weekOfMonth! > 0 {
                timestampText = "\(difference.weekOfMonth!)w"
            }
            
            timestampLabel.text = timestampText
        }
    }
    
    func addTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        isUserInteractionEnabled = true
        addGestureRecognizer(tap)
    }
    
    @objc func cellTapped() {
        if let id = notification?.objectId {
            delegate?.goToDetailVC(withPostId: id)
        }
    }

}
