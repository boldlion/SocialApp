//
//  PhotoCVCell.swift
//  SocialApp
//
//  Created by Bold Lion on 11.10.18.
//  Copyright © 2018 Bold Lion. All rights reserved.
//

import UIKit
import SDWebImage

class PhotoCVCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    var post: Post? {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        if let imageString = post?.photoUrl {
            let url = URL(string: imageString)
            photoImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
        }
    }
}
