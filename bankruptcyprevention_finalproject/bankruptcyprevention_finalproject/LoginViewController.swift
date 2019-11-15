//
//  ViewController.swift
//  bankruptcyprevention_finalproject
//
//  Created by Lawrence on 14/11/19.
//  Copyright © 2019 Lawrence Lim. All rights reserved.
//

import UIKit
import BCryptSwift

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        
        let inputUsername = usernameTextField.text!.lowercased()
        let inputPassword = passwordTextField.text!
        
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
                let result = BCryptSwift.verifyPassword(inputPassword, matchesHash: userPassword)!
                
                if (result) {
                    
                    UserDefaults.standard.set(inputUsername, forKey:"userId");
                    UserDefaults.standard.synchronize();
                    
                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                    
                    let tabBarController = storyBoard.instantiateViewController(withIdentifier: "tabBarController") as! TabBarController
                    self.present(tabBarController, animated:true, completion:nil)
                }
            } else {
                print("Document does not exist")
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

