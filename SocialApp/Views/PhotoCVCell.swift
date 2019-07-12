//
//  PhotoCVCell.swift
//  SocialApp
//
//  Created by Bold Lion on 11.10.18.
//  Copyright © 2018 Bold Lion. All rights reserved.
//

import UIKit
import SDWebImage

protocol PhotoCVCellDelegate: AnyObject {
    func goToDetailVC(withId id: String)
}

class PhotoCVCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    weak var delegate: PhotoCVCellDelegate?
    
    var post: Post? {
        didSet {
            updateView()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addTapGestures()
    }
    
    func updateView() {
        if let imageString = post?.photoUrl {
            let url = URL(string: imageString)
            photoImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
        }
    }
    
    func addTapGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(photoTapped))
        photoImageView.addGestureRecognizer(tap)
        photoImageView.isUserInteractionEnabled = true
    }
    
    @objc func photoTapped() {
        if let id = post?.id {
            delegate?.goToDetailVC(withId: id)
        }
    }
}
