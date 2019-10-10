//
//  DashboardTVCell.swift
//  SocialApp
//
//  Created by Bold Lion on 3.10.18.
//  Copyright © 2018 Bold Lion. All rights reserved.
//

import UIKit
import SVProgressHUD
import SDWebImage
import KILabel
import AVFoundation

protocol DashboardTVCellDelegate: AnyObject {
    func showCommentForPost(with id: String)
    func goToProfile()
    func goToProfileUser(with id: String)
    func goToHashtag(tag: String)
}

class DashboardTVCell: UITableViewCell {

    @IBOutlet weak var photoHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var commentImageView: UIImageView!
    @IBOutlet weak var likeCountButton: UIButton!
    @IBOutlet weak var captionLabel: KILabel!
    @IBOutlet weak var volumeView: UIView!
    @IBOutlet weak var volumeButton: UIButton!
    @IBOutlet weak var timestampLabel: UILabel!
    
    var delegate: DashboardTVCellDelegate?
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        volumeView.isHidden = true
        initialUI()
        addTapGestures()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = UIImage(named: "placeholder")
        postImageView.image = UIImage(named: "profile_placeholder")
        likeCountButton.setTitle("", for: .normal)
        initialUI()
        volumeView.isHidden = true
        if let p = player, let pLayer = playerLayer {
            p.pause()
            pLayer.removeFromSuperlayer()
        }
        timestampLabel.text = ""
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
    var videoIsMuted = true
    
    func updateView() {
        if let caption = post?.caption {
            captionLabel.hashtagLinkTapHandler = { [unowned self] label, string, range in
                let tag = String(string.dropFirst())
                self.delegate?.goToHashtag(tag: tag)
            }
            captionLabel.userHandleLinkTapHandler = { [unowned self] label, string, range in
                let mention = String(string.dropFirst())
                Api.Users.observeUserByUsername(username: mention.lowercased(), completion: { [unowned self] user in
                    guard let currentUserUid = Api.Users.CURRENT_USER?.uid else { return }
                    if let id = user.id {
                        if id == currentUserUid {
                            self.delegate?.goToProfile()
                        }
                        else {
                            self.delegate?.goToProfileUser(with: id)
                        }
                    }
                }, onError: { error in
                    SVProgressHUD.showError(withStatus: error)
                })
            }
            captionLabel.text = caption
        }
        
        if let ratio = post?.ratio {
            photoHeightConstraint.constant = UIScreen.main.bounds.width / ratio
            layoutIfNeeded()
        }
        
        if let image = post?.photoUrl {
            let imageUrl = URL(string: image)
            postImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholder"))
        }
         
        if let videoUrlString = post?.videoUrl, let videoUrl = URL(string: videoUrlString) {
            volumeView.isHidden = false
            player = AVPlayer(url: videoUrl)
            playerLayer = AVPlayerLayer(player: player)
            
            if let pLayer = playerLayer, let vidPlayer = player, let postRatio = post?.ratio {
                
                pLayer.frame = postImageView.frame
                playerLayer?.frame.size.width = UIScreen.main.bounds.width 
                playerLayer?.frame.size.height = UIScreen.main.bounds.width / postRatio
                pLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                contentView.layer.addSublayer(pLayer)
                volumeView.layer.zPosition = 1
                vidPlayer.play()
                vidPlayer.isMuted = videoIsMuted
                layoutIfNeeded()
            }
        }
        
        if let timestamp = post?.timestamp {
            let timestampDate = Date(timeIntervalSince1970: Double(timestamp))
            let now = Date()
            let components = Set<Calendar.Component>([.second, .minute, .hour, .day, .weekOfMonth])
            let difference = Calendar.current.dateComponents(components, from: timestampDate, to: now)
            
            var timestampText = ""
            if difference.second! <= 0 {
                timestampText = "just now"
            }
            if difference.second! > 0 && difference.minute! == 0 {
                timestampText = difference.second! == 1 ? "\(difference.second!) second ago" : "\(difference.second!) seconds ago"
            }
            if difference.minute! > 0 && difference.hour! == 0 {
                timestampText = difference.minute! == 1 ? "\(difference.minute!) minute ago" : "\(difference.minute!) minutes ago"
            }
            if difference.hour! > 0 && difference.day! == 0 {
                timestampText = difference.hour! == 1 ? "\(difference.hour!) hour ago" : "\(difference.hour!) hours ago"
            }
            if difference.day! > 0 && difference.weekOfMonth! == 0 {
                timestampText = difference.day! == 1 ? "\(difference.day!) day ago" : "\(difference.day!) days ago"
            }
            if difference.weekOfMonth! > 0 {
                timestampText = difference.weekOfMonth! == 1 ? "\(difference.weekOfMonth!) week ago" : "\(difference.weekOfMonth!) weeks ago"
            }
            
            timestampLabel.text = timestampText
        }
        if let p = post {
            updateLike(post: p)
        }
    }
    
    @IBAction func volumeTapped(_ sender: UIButton) {
        if videoIsMuted {
            videoIsMuted = !videoIsMuted
            volumeButton.setImage(UIImage(named: "icon_volume"), for: .normal)
        }
        else {
            videoIsMuted = !videoIsMuted
            volumeButton.setImage(UIImage(named: "icon_mute"), for: .normal)
        }
        player?.isMuted = videoIsMuted
    }
    
    func updateLike(post: Post) {
        
        var imageName = ""
        
        if let isPostLiked = post.isLiked {
            if isPostLiked == true {
                imageName = "post_likeSelected"
            }
            else {
                imageName = "post_like"
            }
        }
        else {
            imageName = "post_like"
        }
        
        likeImageView.image = UIImage(named: imageName)
        
        guard let count = post.likesCount else { return } 
        if count != 0 && count != 1 {
            likeCountButton.setTitle("\(count) likes", for: .normal)
        }
        else if count == 1 {
            likeCountButton.setTitle("\(count) like", for: .normal)
        }
        else {
            likeCountButton.setTitle("Be the first to like this", for: .normal)
        }
    }
    
    func updateUserInfo() {
        if let name = user?.displayName {
            nameLabel.text = name
        }
        
        if let imageString = user?.profileImageString {
            let imageUrl = URL(string: imageString)
            profileImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "profile_placeholder"))
        }
    }
    
    @objc func commentTapped() {
        if let id = post?.id {
            delegate?.showCommentForPost(with: id)
        }
    }
    
    @objc func likeTapped() {
        guard let id = post?.id else { return }
        Api.Post.incrementOrDecrementLikesOfPost(withId: id, completion: { [unowned self] post in
            self.post?.likes = post.likes
            self.post?.isLiked = post.isLiked
            self.post?.likesCount = post.likesCount
            self.updateLike(post: post)
        }, onError: { error in
            SVProgressHUD.showError(withStatus: error)
        })
    }
    
    func initialUI() {
        nameLabel.text = ""
        captionLabel.text = ""
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
    }
    
    func addTapGestures() {
        let tapComment = UITapGestureRecognizer(target: self, action: #selector(commentTapped))
        commentImageView.addGestureRecognizer(tapComment)
        commentImageView.isUserInteractionEnabled = true
        
        let tapLike = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        likeImageView.addGestureRecognizer(tapLike)
        likeImageView.isUserInteractionEnabled = true
        
        let tapUsername = UITapGestureRecognizer(target: self, action: #selector(usernameTapped))
        nameLabel.addGestureRecognizer(tapUsername)
        nameLabel.isUserInteractionEnabled = true
        
        let tapProfileImage = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileImageView.addGestureRecognizer(tapProfileImage)
        profileImageView.isUserInteractionEnabled = true
    }
    
    @objc func usernameTapped() {
        guard let currentUserUid = Api.Users.CURRENT_USER?.uid else { return }
        if let id = user?.id {
            if id == currentUserUid {
                delegate?.goToProfile()
            }
            else {
                delegate?.goToProfileUser(with: id)
            }
        }
    }
    
    @objc func profileImageTapped() {
        guard let currentUserUid = Api.Users.CURRENT_USER?.uid else { return }
        if let id = user?.id {
            if id == currentUserUid {
                delegate?.goToProfile()
            }
            else {
                delegate?.goToProfileUser(with: id)
            }
        }
    }
    
    deinit {
        print("Dashboard Cell Deinitialised")
    }
}
