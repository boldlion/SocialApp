//
//  FilterCVCell.swift
//  SocialApp
//
//  Created by Bold Lion on 26.10.18.
//  Copyright © 2018 Bold Lion. All rights reserved.
//

import UIKit

class FilterCVCell: UICollectionViewCell {
    
    
    @IBOutlet weak var filterPhoto: UIImageView!
    
    override func prepareForReuse() {
        filterPhoto.image = UIImage()
    }
    
}
