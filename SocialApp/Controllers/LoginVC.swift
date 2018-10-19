//
//  ViewController.swift
//  SocialApp
//
//  Created by Bold Lion on 30.09.18.
//  Copyright © 2018 Bold Lion. All rights reserved.
//

import UIKit
import SVProgressHUD

class LoginVC: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textFielsdDelegate()
        loginButton.isEnabled = false
        handleTextFields()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Api.Users.CURRENT_USER != nil {
            self.performSegue(withIdentifier: "SegueToTabbar", sender: nil)
        }
    }

    @IBAction func loginTapped(_ sender: UIButton) {
        view.endEditing(true)
        SVProgressHUD.setDefaultMaskType(.gradient)
        SVProgressHUD.show(withStatus: "Signing in...")
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        AuthApi.loginWith(email: email, password: password, onSuccess: {
            SVProgressHUD.dismiss()
            self.performSegue(withIdentifier: "SegueToTabbar", sender: nil)
        }, onError: {
            error in
            SVProgressHUD.showError(withStatus: error!)
        })
    }
    
    @IBAction func lostPassTapped(_ sender: UIButton) {
 
    }
    
    @IBAction func registerTapped(_ sender: UIButton) {
        
    }
}

extension LoginVC : UITextFieldDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func handleTextFields() {
        emailTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
    }
    
    func textFielsdDelegate() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    @objc func textFieldDidChange() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty
            else {
                loginButton.setTitleColor(.gray, for: .normal)
                loginButton.isEnabled = false
                return
            }
        loginButton.isEnabled = true
        loginButton.setTitleColor(.white, for: .normal)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
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
    
}
