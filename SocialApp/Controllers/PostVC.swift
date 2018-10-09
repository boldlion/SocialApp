//
//  PostVC.swift
//  SocialApp
//
//  Created by Bold Lion on 30.09.18.
//  Copyright © 2018 Bold Lion. All rights reserved.
//

import UIKit
import SVProgressHUD

class PostVC: UIViewController {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var clearButton: UIBarButtonItem!
    
    var selectedImage: UIImage?
    
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
    
    @IBAction func shareTapped(_ sender: UIButton) {
        view.endEditing(true)
        SVProgressHUD.show(withStatus: "Waiting...")
        if let postImage = selectedImage, let imageData = postImage.jpegData(compressionQuality: 0.1)  {
            DatabaseService.sendImageToStorage(with: imageData, onError: { error in
                SVProgressHUD.showError(withStatus: error)
                return
            }, onSuccess: { storagePostImageUrlString in
                self.sendPostDataToDatabase(photoUrlString: storagePostImageUrlString)
            })
        }
        else {
            SVProgressHUD.showError(withStatus: "Image is mandatory, please, select one.")
        }
    }
    
    @objc func handleSelectPhoto() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }
    
    func sendPostDataToDatabase(photoUrlString: String) {
        guard let caption = captionTextView.text else { return }
        DatabaseService.sendPostDataToDatabase(photoImageUrlString: photoUrlString, caption: caption, onSuccess: {
            SVProgressHUD.dismiss()
            self.clear()
            self.tabBarController?.selectedIndex = 0
         }, onError: { error in
            SVProgressHUD.showError(withStatus: error)
            return
        })
    }
    
    func handlePost() {
        if selectedImage != nil {
            clearButton.isEnabled = true
            shareButton.isEnabled = true
            shareButton.backgroundColor = UIColor(red: 218/255, green: 117/255, blue: 83/255, alpha: 1.0)
            shareButton.setTitleColor(.white, for: .normal)
        }
        else {
            shareButton.isEnabled = false
            clearButton.isEnabled = false
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
        self.captionTextView.text = ""
        self.selectedImage = nil
        self.photoImageView.image = UIImage(named: "placeholder")
    }
}

extension PostVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImage = image
            photoImageView.image = image
            shareButton.isEnabled = true
        }
        dismiss(animated: true, completion: nil)
    }
}
