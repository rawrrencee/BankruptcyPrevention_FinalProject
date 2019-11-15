//
//  RegisterViewController.swift
//  bankruptcyprevention_finalproject
//
//  Created by Lawrence on 14/11/19.
//  Copyright © 2019 Lawrence Lim. All rights reserved.
//

import UIKit
import BCryptSwift

class RegisterViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        
        let inputUsername = usernameTextField.text!.lowercased()
        let inputPassword = passwordTextField.text!
        
        //Check if username exists
        let userReference = FirestoreReferenceManager.users.document(inputUsername)
        
        userReference.getDocument { (document, error) in
            if let document = document, document.exists {
                let alert = UIAlertController(title: "Username already exists", message: "Please use a different username.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            } else {
                let salt = BCryptSwift.generateSalt()
                
                let passwordHash = BCryptSwift.hashPassword(inputPassword, withSalt: salt)
                FirestoreReferenceManager.users.document(inputUsername).setData(["password": passwordHash!]) {
                    (err) in
                    if let err = err {
                        print (err.localizedDescription)
                    }
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == usernameTextField {
            textField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    
}
