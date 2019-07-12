//
//  FilterVC.swift
//  SocialApp
//
//  Created by Bold Lion on 24.10.18.
//  Copyright © 2018 Bold Lion. All rights reserved.
//

import UIKit

protocol FilterVCDelegate: AnyObject {
    func updatePhoto(image: UIImage)
}

class FilterVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var filterPhotoView: UIImageView!
    
    weak var delegate: FilterVCDelegate?
    var selectedPhoto = UIImage()
    var filters = [ "CIColorCube", "CIPhotoEffectMono", "CIColorMonochrome", "CIColorPosterize", "CIFalseColor", "CIMaximumComponent", "CIMinimumComponent", "CIPhotoEffectChrome", "CIPhotoEffectFade" ]
    
    let context = CIContext(options: nil)
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        filterPhotoView.image = selectedPhoto
    }
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextTapped(_ sender: UIButton) {
        if let image = filterPhotoView.image {
            delegate?.updatePhoto(image: image)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
         let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
}

extension FilterVC : UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  filters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCell", for: indexPath) as! FilterCVCell
        let newImage = resizeImage(image: selectedPhoto, newWidth: 100)
        let ciImage = CIImage(image: newImage)
        let filter = CIFilter(name: filters[indexPath.item])
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        if let filteredImage = filter?.value(forKey: kCIOutputImageKey) as? CIImage {
            let result = context.createCGImage(filteredImage, from: filteredImage.extent)
            cell.filterPhoto.image = UIImage(cgImage: result!)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let ciImage = CIImage(image: selectedPhoto)
        let filter = CIFilter(name: filters[indexPath.item])
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        if let filteredImage = filter?.value(forKey: kCIOutputImageKey) as? CIImage {
            let result = context.createCGImage(filteredImage, from: filteredImage.extent)
            filterPhotoView.image = UIImage(cgImage: result!)
        }
    }
}
