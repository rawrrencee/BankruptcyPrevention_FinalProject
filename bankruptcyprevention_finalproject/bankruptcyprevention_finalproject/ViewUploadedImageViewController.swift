//
//  ViewUploadedImageViewController.swift
//  bankruptcyprevention_finalproject
//
//  Created by Lawrence on 9/12/19.
//  Copyright © 2019 Lawrence Lim. All rights reserved.
//

import UIKit

class ViewUploadedImageViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    var uploadedImage: UIImage? = UIImage()
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (uploadedImage != nil) {
            imageView.image = uploadedImage!
        }
    }
    
}
