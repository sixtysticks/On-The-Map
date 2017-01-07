//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by David Gibbs on 03/01/2017.
//  Copyright © 2017 SixtySticks. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    var udacityClient: UdacityClient!
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        UdacityClient.sharedInstance().authenticateUser(username: usernameTextField.text!, password: passwordTextField.text!) { (success, error) in
            if success {
                self.completeLogin()
            } else {
                print("There was an error during authentication: \(error)")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        configureBackground()
    }
    
    func completeLogin() {
        print("Completed login")
    }
    
    func configureBackground() {
        let backgroundGradient = CAGradientLayer()
        let colorTop = UIColor(red: 1.0, green: 0.608, blue: 0.039, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 1.0, green: 0.431, blue: 0.0, alpha: 1.0).cgColor
        backgroundGradient.colors = [colorTop, colorBottom]
        backgroundGradient.locations = [0.0, 1.0]
        backgroundGradient.frame = view.frame
        view.layer.insertSublayer(backgroundGradient, at: 0)
    }

}

