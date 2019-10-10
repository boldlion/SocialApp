//
//  SettingTVC.swift
//  SocialApp
//
//  Created by Bold Lion on 18.10.18.
//  Copyright © 2018 Bold Lion. All rights reserved.
//

import UIKit
import SVProgressHUD
import SDWebImage

protocol SettingsTVCDelegate : AnyObject {
    func updateUserInfo()
}

class SettingTVC: UITableViewController {

    var user: UserModel!
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    weak var delegate: SettingsTVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Edit Profile"
        nameTextField.delegate = self
        emailTextField.delegate = self
        fetchUser()
    }
    
    func fetchUser() {
        Api.Users.observeCurrentUser(completion: { [unowned self] user in
            self.user = user
            self.nameTextField.text = user.displayName
            self.emailTextField.text = user.email
            
            if let photoString = user.profileImageString {
                let url = URL(string: photoString)
                self.profileImage.sd_setImage(with: url)
            }
        }, onError: { error in
            SVProgressHUD.showError(withStatus: error)
        })
    }

    @IBAction func saveTapped(_ sender: UIButton) {
        guard let name = nameTextField.text else { return }
        guard let email = emailTextField.text else { return }
        if let profileImg = profileImage.image, let imageData = profileImg.jpegData(compressionQuality: 0.1)  {
            SVProgressHUD.showProgress(5, status: "Updating...")
            Api.Auth.updateUserInformation(email: email, displayName: name, imageData: imageData, onSuccess: { [unowned self] in
                SVProgressHUD.showSuccess(withStatus: "Updated!")
                self.delegate?.updateUserInfo()
            }, onError: { errorMessage in
                SVProgressHUD.showError(withStatus: errorMessage!)
            })
        }
    }
    
    @IBAction func logoutTapped(_ sender: UIButton) {
        AuthApi.logout(onSuccess: { [unowned self] in
            let storyboard = UIStoryboard(name: "Auth", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC")
            loginVC.modalPresentationStyle = .fullScreen
            self.present(loginVC, animated: true, completion: nil)
        }, onError: { error in
            SVProgressHUD.showError(withStatus: error)
        })
    }
    
    @IBAction func changePhoto(_ sender: UIButton) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }
    
}

extension SettingTVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImage.image = image
        }
        dismiss(animated: true, completion: nil)
    }
}

extension SettingTVC : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
