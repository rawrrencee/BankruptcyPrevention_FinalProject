//
//  ViewController.swift
//  bankruptcyprevention_finalproject
//
//  Created by Lawrence on 14/11/19.
//  Copyright © 2019 Lawrence Lim. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    @IBAction func loginButtonPressed(_ sender: Any) {
       
        /*
        FirestoreReferenceManager.users.document("lawrencelim").setData(["password": "123"]) {
            (err) in
            if let err = err {
                print (err.localizedDescription)
            }
        }
        */
        
        let inputUsername = usernameTextField.text
        let inputPassword = passwordTextField.text
        
        let userReference = FirestoreReferenceManager.users.document(inputUsername!)
        
        userReference.getDocument { (document, error) in
            if let document = document, document.exists {
                
                //let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                
                //print("Document data: \(dataDescription)")
                
                let userPassword = document.get("password") as! String
                if (inputPassword == userPassword) {
                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                    
                    let tabBarController = storyBoard.instantiateViewController(withIdentifier: "tabBarController") as! TabBarController
                    self.present(tabBarController, animated:true, completion:nil)
                }
            } else {
                print("Document does not exist")
            }
        }
        
    }
    

}

