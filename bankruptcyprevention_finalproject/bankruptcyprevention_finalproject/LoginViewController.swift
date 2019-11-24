//
//  ViewController.swift
//  bankruptcyprevention_finalproject
//
//  Created by Lawrence on 14/11/19.
//  Copyright © 2019 Lawrence Lim. All rights reserved.
//

import UIKit
import BCryptSwift
import MaterialComponents

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameTextField: MDCTextField!
    @IBOutlet weak var passwordTextField: MDCTextField!
    
    var usernameController: MDCTextInputControllerOutlined?
    var passwordController: MDCTextInputControllerOutlined?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        usernameController = MDCTextInputControllerOutlined(textInput: usernameTextField)
        passwordController = MDCTextInputControllerOutlined(textInput: passwordTextField)
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        
        let inputUsername = usernameTextField.text!.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let inputPassword = passwordTextField.text!
        
        if (inputUsername.isEmpty || inputPassword.isEmpty) {
            let alert = UIAlertController(title: "Blank credentials", message: "Please fill in a valid username and password.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            
            return
        }
        
        //backdoor
        if (inputUsername == "admin" && inputPassword == "1234") {
            UserDefaults.standard.set(inputUsername, forKey:"userId");
            UserDefaults.standard.synchronize();
            
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            
            let tabBarController = storyBoard.instantiateViewController(withIdentifier: "tabBarController") as! TabBarController
            self.present(tabBarController, animated:true, completion:nil)
        }
        
        let userReference = FirestoreReferenceManager.users.document(inputUsername)
        
        userReference.getDocument { (document, error) in
            if let document = document, document.exists {
                
                //let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                
                //print("Document data: \(dataDescription)")
                
                let userPassword = document.get("password") as! String
                let saveToCloud = document.get("saveToCloud") as! Int
                let result = BCryptSwift.verifyPassword(inputPassword, matchesHash: userPassword)!
                
                if (result) {
                    
                    UserDefaults.standard.set(inputUsername, forKey:"userId");
                    UserDefaults.standard.set(saveToCloud, forKey:"saveToCloud");
                    UserDefaults.standard.synchronize();
                    
                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                    
                    let tabBarController = storyBoard.instantiateViewController(withIdentifier: "tabBarController") as! TabBarController
                    self.present(tabBarController, animated:true, completion:nil)
                }
            } else {
                let alert = UIAlertController(title: "Invalid Account", message: "The username/password entered does not exist.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
                self.present(alert, animated: true)
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

