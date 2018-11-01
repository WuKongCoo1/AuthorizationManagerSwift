//
//  ViewController.swift
//  AuthorizationManagerSwift
//
//  Created by Jacky on 2018/10/31.
//  Copyright © 2018 FinupGroup. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func contact(_ sender: Any) {
        AuthorizationManager.checkContactsAuthorization { (success) in
            
        }
    }
    @IBAction func location(_ sender: Any) {
        AuthorizationManager.checkLocationAutorization(locationType: .aways) { (result, location) in
            
        }
    }
    @IBAction func photoLibrary(_ sender: Any) {
        AuthorizationManager.checkPhotoAutorization { (result) in
            
        }
    }
    @IBAction func mic(_ sender: Any) {
        AuthorizationManager.checkAudioAuthorization { (result) in
            
        }
    }
    @IBAction func camera(_ sender: Any) {
        AuthorizationManager.checkCameraAuthorization { (result) in
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }


}

