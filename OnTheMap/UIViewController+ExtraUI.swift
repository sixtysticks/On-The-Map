//
//  UIViewController+ExtraUI.swift
//  OnTheMap
//
//  Created by David Gibbs on 15/01/2017.
//  Copyright © 2017 SixtySticks. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showActivitySpinner(_ spinner: UIActivityIndicatorView!, style: UIActivityIndicatorViewStyle) {
        DispatchQueue.main.async {
            let activitySpinner = spinner
            activitySpinner?.activityIndicatorViewStyle = style
            activitySpinner?.hidesWhenStopped = true
            activitySpinner?.isHidden = false
            activitySpinner?.startAnimating()
        }
    }
    
    func hideActivitySpinner(_ spinner: UIActivityIndicatorView!) {
        DispatchQueue.main.async {
            let activitySpinner = spinner
            activitySpinner?.isHidden = true
            activitySpinner?.stopAnimating()
        }
    }
    
    func showAlert(_ error: String) {
        let alert = UIAlertController(title: "Uh-oh!", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func canVerifyUrl (urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url  = NSURL(string: urlString) {
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
    
    func setUpBackground(_ view: UIView) {
        let backgroundGradient = CAGradientLayer()
        let colorTop = UIColor(red: 1.0, green: 0.608, blue: 0.039, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 1.0, green: 0.431, blue: 0.0, alpha: 1.0).cgColor
        backgroundGradient.colors = [colorTop, colorBottom]
        backgroundGradient.locations = [0.0, 1.0]
        backgroundGradient.frame = view.frame
        view.layer.insertSublayer(backgroundGradient, at: 0)
    }
    
    func setupTextField(_ delegate: UITextFieldDelegate, _ textfield: UITextField, hasPadding: Bool) {
        textfield.delegate = delegate
        textfield.font = UIFont(name: "Roboto-Regular", size: 18)
        textfield.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.3)
        textfield.textColor = UIColor.black
        
        if hasPadding {
            let paddingRect = CGRect(x: 0, y: 0, width: 15, height: textfield.frame.height)
            textfield.leftView = UIView(frame: paddingRect)
            textfield.leftViewMode = UITextFieldViewMode.always
        }
    }
    
}
