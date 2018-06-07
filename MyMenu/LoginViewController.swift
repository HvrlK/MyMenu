//
//  LoginViewController.swift
//  MyMenu
//
//  Created by Vitalii Havryliuk on 6/7/18.
//  Copyright © 2018 Vitalii Havryliuk. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class LoginViewController: UIViewController, GIDSignInUIDelegate {
    
    @IBOutlet weak var signInButton: UIButton!
    
    @IBAction func signInButtonTapped(_ sender: UIButton) {
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }    

}
