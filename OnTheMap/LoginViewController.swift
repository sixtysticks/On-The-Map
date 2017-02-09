//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by David Gibbs on 03/01/2017.
//  Copyright © 2017 SixtySticks. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpLink: UIButton!
    @IBOutlet weak var activityViewSpinner: UIActivityIndicatorView!
    
    // MARK: IBActions
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        
        self.view.endEditing(true)
        
        showActivitySpinner(activityViewSpinner, style: .whiteLarge)
        
        UdacityClient.sharedInstance().authenticateUser(username: usernameTextField.text!, password: passwordTextField.text!) { (result, error) in
            
            if error != nil {
                DispatchQueue.main.async {
                    self.hideActivitySpinner(self.activityViewSpinner)
                }
                self.showAlert(error!)
            } else {
                DispatchQueue.main.async {
                    self.hideActivitySpinner(self.activityViewSpinner)
                    self.completeLogin()
                }
            }
        }
    }
    
    @IBAction func signUpLinkPressed(_ sender: UIButton) {
        UIApplication.shared.open(URL(string: UdacityConstants.SignUpUrl)!, options: [:], completionHandler: nil)
    }
    
    // Custom methods
    
    func completeLogin() {
        usernameTextField.text = ""
        passwordTextField.text = ""
        
        if let mapAndTableTabController = storyboard?.instantiateViewController(withIdentifier: "MapAndTableTabController") {
            present(mapAndTableTabController, animated: true, completion: nil)
        }
    }
    
    // MARK: ViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Background
        setUpBackground(self.view)
        
        // Title
        mainTitle.font = UIFont(name: "Roboto-Medium", size: 26)
        
        // Textfields
        setupTextField(self, usernameTextField, hasPadding: true)
        setupTextField(self, passwordTextField, hasPadding: true)
        
        // Login Button
        loginButton.titleLabel?.font = UIFont(name: "Roboto-Medium", size: 20)
        loginButton.backgroundColor = UIColor(red: 0.956, green: 0.333, blue: 0.0, alpha: 1.0)
        
        // Signup link
        signUpLink.titleLabel?.font = UIFont(name: "Roboto-Regular", size: 15)
        
        // Set activity spinner to hidden
        activityViewSpinner.isHidden = true
    }
    
    // MARK: TextField methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.backgroundColor = UIColor.white
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        if (textField.text?.isEmpty)! {
            textField.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.3)
        } else {
            textField.backgroundColor = UIColor.white
        }
    }
}

