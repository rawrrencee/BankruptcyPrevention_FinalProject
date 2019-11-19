//
//  ProfileViewController.swift
//  bankruptcyprevention_finalproject
//
//  Created by Lawrence on 10/11/19.
//  Copyright © 2019 Lawrence Lim. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    let userId = UserDefaults.standard.object(forKey: "userId") as! String
    let saveToCloud = UserDefaults.standard.object(forKey: "saveToCloud") as! Int
    
    @IBOutlet weak var saveToCloudSwitch: UISwitch!
    
    @IBAction func saveToCloudSwitchSelected(_ sender: Any) {
        if (saveToCloudSwitch.isOn) {
            FirestoreReferenceManager.users.document(userId).updateData(["saveToCloud": 1]) {
                (err) in
                if let err = err {
                    print (err.localizedDescription)
                }
            }
        } else {
            FirestoreReferenceManager.users.document(userId).updateData(["saveToCloud": 0]) {
                (err) in
                if let err = err {
                    print (err.localizedDescription)
                }
            }
        }
    }
    
    
    @IBAction func logoutButton(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let loginViewController = storyBoard.instantiateViewController(withIdentifier: "loginViewController") as! LoginViewController
        self.present(loginViewController, animated:true, completion:nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if (saveToCloud == 1) {
            saveToCloudSwitch.setOn(true, animated: false)
        } else {
            saveToCloudSwitch.setOn(false, animated: false)
        }
    }

}
