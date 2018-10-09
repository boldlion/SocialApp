//
//  RegisterVC.swift
//  SocialApp
//
//  Created by Bold Lion on 30.09.18.
//  Copyright © 2018 Bold Lion. All rights reserved.
//

import UIKit
import SVProgressHUD

class RegisterVC: UIViewController {

    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerButton.isEnabled = false
        handleTextFields()
        addTapGestureToUserImage()
    }
    @IBAction func cancelTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func registerTapped(_ sender: UIButton) {
        view.endEditing(true)
        SVProgressHUD.show(withStatus: "Waiting...")
        
        if let image = selectedImage {
            let data = image.jpegData(compressionQuality: 0.1)
            AuthApi.registerWith(data        : data!,
                                 displayName : displayNameTextField.text!,
                                 username    : usernameTextField.text!,
                                 email       : emailTextField.text!,
                                 password    : passwordTextField.text!,
                                 onSuccess:  {
                                    SVProgressHUD.dismiss()
                                    self.performSegue(withIdentifier: "SegueRegisterToTabbar", sender: nil)
                                 },
                                 onError: { error in
                                    SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.gradient)
                                    SVProgressHUD.showError(withStatus: error!)
            })
        }
    }
    
    func addTapGestureToUserImage() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTapped))
        userProfileImage.addGestureRecognizer(tap)
        userProfileImage.isUserInteractionEnabled = true
    }
    
    @objc func handleProfileImageTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
}

extension RegisterVC: UITextFieldDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func handleTextFields() {
        displayNameTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
        usernameTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
    }
    
    func textFielsdDelegate() {
        displayNameTextField.delegate = self
        usernameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case displayNameTextField:
            usernameTextField.becomeFirstResponder()
            return true
        case usernameTextField:
            emailTextField.becomeFirstResponder()
            return true
        case emailTextField:
            passwordTextField.becomeFirstResponder()
            return true
        case passwordTextField:
            passwordTextField.resignFirstResponder()
            return true
        default:
            break
        }
        return true
    }
    
    @objc func textFieldDidChange()  {
        guard let username = usernameTextField.text,       !username.isEmpty,
            let displayName = displayNameTextField.text, !displayName.isEmpty,
            let email = emailTextField.text,             !email.isEmpty,
            let password = passwordTextField.text,       !password.isEmpty,
            selectedImage != nil
            else {
                registerButton.setTitleColor(.gray, for: .normal)
                registerButton.isEnabled = false
                return
        }
        registerButton.isEnabled = true
        registerButton.setTitleColor(.white, for: .normal)
    }
    
}

extension RegisterVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImage = image
            userProfileImage.image = image
        }
        dismiss(animated: true, completion: nil)
    }
}
