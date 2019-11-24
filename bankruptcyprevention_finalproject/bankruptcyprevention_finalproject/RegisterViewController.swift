//
//  RegisterViewController.swift
//  bankruptcyprevention_finalproject
//
//  Created by Lawrence on 14/11/19.
//  Copyright © 2019 Lawrence Lim. All rights reserved.
//

import UIKit
import BCryptSwift
import MaterialComponents

class RegisterViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var usernameTextField: MDCTextField!
    @IBOutlet weak var passwordTextField: MDCTextField!
    @IBOutlet weak var saveToCloudSwitch: UISwitch!
    
    var usernameController: MDCTextInputControllerOutlined?
    var passwordController: MDCTextInputControllerOutlined?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        usernameController = MDCTextInputControllerOutlined(textInput: usernameTextField)
        passwordController = MDCTextInputControllerOutlined(textInput: passwordTextField)
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        
        let inputUsername = usernameTextField.text!.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let inputPassword = passwordTextField.text!
        
        if (inputUsername.isEmpty || inputPassword.isEmpty) {
            let alert = UIAlertController(title: "Blank credentials", message: "Please fill in a valid username and password.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            
            return
        }
        
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
                
                if (self.saveToCloudSwitch.isOn) {
                    
                    FirestoreReferenceManager.users.document(inputUsername).setData(["password": passwordHash!, "saveToCloud": 1]) {
                        (err) in
                        if let err = err {
                            print (err.localizedDescription)
                        }
                    }
                } else {
                    FirestoreReferenceManager.users.document(inputUsername).setData(["password": passwordHash!, "saveToCloud": 0]) {
                        (err) in
                        if let err = err {
                            print (err.localizedDescription)
                        }
                    }
                }
                
                self.dismiss(animated: true, completion: nil)
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
