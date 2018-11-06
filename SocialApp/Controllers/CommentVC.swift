//
//  CommentVC.swift
//  SocialApp
//
//  Created by Bold Lion on 5.10.18.
//  Copyright © 2018 Bold Lion. All rights reserved.
//

import UIKit
import SVProgressHUD

class CommentVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var constraintToBottom: NSLayoutConstraint!
    
    var postId: String!

    var comments = [Comment]()
    var users = [UserModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.estimatedRowHeight = 428
        tableView.rowHeight = UITableView.automaticDimension
        handleTextField()
        fetchComments()
        setKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    func fetchComments() {
        activityIndicator.startAnimating()
        guard let id = postId else { return }
        Api.Post_Comment.observePostCommentsForPost(withId: id, completion: { commentId in
            Api.Comment.observeCommentsForPost(withId: commentId, completion: { comment in
                guard let userId = comment.uid else { return }
                self.fetchUsers(withId: userId, completion: {
                    self.stopAndHideActivityIndicator()
                    self.comments.append(comment)
                    self.tableView.reloadData()
                }, onErrror: { errorUsers in
                    self.stopAndHideActivityIndicator()
                    SVProgressHUD.showError(withStatus: errorUsers)
                })
            }, onError: { err in
                self.stopAndHideActivityIndicator()
                SVProgressHUD.showError(withStatus: err)
            })
        }, onError: { error in
            self.stopAndHideActivityIndicator()
            SVProgressHUD.showError(withStatus: error)
        })
    }
    
    func fetchUsers(withId id: String, completion: @escaping () -> Void, onErrror: @escaping (String) -> Void) {
        Api.Users.fetchUser(withId: id, completion: { user in
            self.users.append(user)
            completion()
        }, onError: { error in
            self.stopAndHideActivityIndicator()
            SVProgressHUD.showError(withStatus: error)
        })
    }
    
    @IBAction func sendTapped(_ sender: UIButton) {
        view.endEditing(true)
        SVProgressHUD.show(withStatus: "Waiting...")
        guard let id = postId else { return }
        if let comment = commentTextField.text  {
            DatabaseService.sendComment(with: comment, postId: id, onError: { error in
                SVProgressHUD.showError(withStatus: error)
           }, onSuccess: {
                self.empty()
           })
        }
    }
    
    func handleTextField() {
        commentTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc func textFieldDidChange() {
        guard let comment = commentTextField.text, !comment.isEmpty else {
            sendButton.setTitleColor(.lightGray, for: .normal)
            sendButton.isEnabled = false
            return
        }
        sendButton.setTitleColor(Colors.tint, for: .normal)
        sendButton.isEnabled = true
    }
    
    func empty() {
        self.view.endEditing(true)
        SVProgressHUD.dismiss()
        self.commentTextField.text = ""
        self.sendButton.isEnabled = false
        sendButton.setTitleColor(.lightGray, for: .normal)
    }
    
    func stopAndHideActivityIndicator() {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.hidesWhenStopped = true
    }
    
    func setKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {

            UIView.animate(withDuration: 0.3, animations: {
                self.constraintToBottom.constant = -keyboardSize.height
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0, animations: {
            self.constraintToBottom.constant = 0
            self.view.layoutIfNeeded()
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true )
    }
}

extension CommentVC : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentTVCell
        let comment = comments[indexPath.row]
        let user = users[indexPath.row]
        cell.comment = comment
        cell.delegateCommentTVCell = self
        cell.user = user
        return cell
    }
}

extension CommentVC : CommentTVCellDelegate {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CommentToProfileUserSegue" {
            let profileUserVC = segue.destination as! ProfileUserVC
            let userId = sender as! String
            profileUserVC.userId = userId
        }
        if segue.identifier == "CommentToHashtag" {
            let hashtagVC = segue.destination as! HashtagVC
            let tag = sender as! String
            hashtagVC.tag = tag
        }
    }
    
    func goToHashtag(tag: String) {
        performSegue(withIdentifier: "CommentToHashtag", sender: tag)
    }
    
    func goToProfileUser(with id: String) {
        performSegue(withIdentifier: "CommentToProfileUserSegue", sender: id)
    }
    
    func goToProfile() {
        performSegue(withIdentifier: "CommentToProfileSegue", sender: nil)
    }
    
}


