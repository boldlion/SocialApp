//
//  PostVC.swift
//  SocialApp
//
//  Created by Bold Lion on 30.09.18.
//  Copyright © 2018 Bold Lion. All rights reserved.
//

import UIKit
import SVProgressHUD
import AVFoundation

class PostVC: UIViewController {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var clearButton: UIBarButtonItem!
    @IBOutlet weak var filterButton: UIBarButtonItem!
    
    var selectedImage: UIImage?
    var videoUrl: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "New Post"
        addTapGestureToImageView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handlePost()
    }
    
    @IBAction func clearTapped(_ sender: UIBarButtonItem) {
        clear()
        handlePost()
    }
    
    @IBAction func filtersTapped(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "PostVCToFilterVC", sender: self.selectedImage)
    }
    
    @IBAction func shareTapped(_ sender: UIButton) {
        view.endEditing(true)
        SVProgressHUD.show(withStatus: "Waiting...")
        if let postImage = selectedImage, let imageData = postImage.jpegData(compressionQuality: 0.1)  {
            let photoRatio = postImage.size.width / postImage.size.height
            
            DatabaseService.uploadDataToServer(data: imageData, videoUrl: videoUrl, ratio: photoRatio, caption: captionTextView.text!, onSuccess: { [unowned self] in
                SVProgressHUD.dismiss()
                self.clear()
                self.tabBarController?.selectedIndex = 0
            }, onError: { error in
                SVProgressHUD.showError(withStatus: error)
            })
        }
        else {
            SVProgressHUD.showError(withStatus: "Image/Video is mandatory, please, select one.")
            return
        }
    }
    
    @objc func handleSelectPhoto() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.mediaTypes = [ "public.image", "public.movie"]
        present(pickerController, animated: true, completion: nil)
    }
    
    func handlePost() {
        if selectedImage != nil {
            clearButton.isEnabled = true
            clearButton.tintColor = Colors.tint
            filterButton.isEnabled = true
            filterButton.tintColor = Colors.tint
            shareButton.isEnabled = true
            shareButton.backgroundColor = Colors.tint
            shareButton.setTitleColor(.white, for: .normal)
        }
        else {
            clearButton.isEnabled = false
            clearButton.tintColor = .darkGray
            filterButton.isEnabled = false
            filterButton.tintColor = .darkGray
            shareButton.isEnabled = false
            shareButton.backgroundColor = .darkGray
            shareButton.setTitleColor(.lightGray, for: .normal)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func addTapGestureToImageView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleSelectPhoto))
        photoImageView.addGestureRecognizer(tap)
        photoImageView.isUserInteractionEnabled = true
    }
    
    func clear() {
        captionTextView.text = ""
        selectedImage = nil
        photoImageView.image = UIImage(named: "placeholder")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PostVCToFilterVC" {
            let filterVC = segue.destination as! FilterVC
            filterVC.delegate = self
            if let chosenImage = selectedImage {
                filterVC.selectedPhoto = chosenImage
            }
        }
    }
}

extension PostVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            if let thumbnail = self.generateThumbnailForImage(videoUrl) {
                self.videoUrl = videoUrl
                self.photoImageView.image = thumbnail
                self.selectedImage = thumbnail
            }
        }
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImage = image
            photoImageView.image = image
        }
        dismiss(animated: true, completion: nil)
        handlePost()
    }
    
    func generateThumbnailForImage(_ fileUrl: URL) -> UIImage? {
        let asset = AVAsset(url: fileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        do {
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 10), actualTime: nil) // 1 sec
            return UIImage(cgImage: thumbnailCGImage)
            
        } catch let err {
            SVProgressHUD.showError(withStatus: err.localizedDescription)
        }
        return nil
    }
}

extension PostVC: FilterVCDelegate {
    
    func updatePhoto(image: UIImage) {
        photoImageView.image = image
        selectedImage = image
    }
}
