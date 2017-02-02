//
//  InfoPostingViewController.swift
//  OnTheMap
//
//  Created by David Gibbs on 26/01/2017.
//  Copyright © 2017 SixtySticks. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class InfoPostingViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var formView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapElements: UIView!
    
    @IBAction func findButtonPressed(_ sender: UIButton) {
        
        let geocoder = CLGeocoder()
        
        guard let place = textField.text else {
            self.showAlert("Please enter a location")
            return
        }
        
        geocoder.geocodeAddressString(place) { (placemarks, error) in
            
            if error != nil {
                self.showAlert("Can't find location")
            } else {
                self.mapElements.isHidden = false
                self.formView.isHidden = true
                // Add spinner
                
                let placemark = placemarks?.first
                
                if let placemark = placemark {
                    let coordinate = placemark.location?.coordinate
                    print("Latitude: \(coordinate?.latitude) // Longitude: \(coordinate?.longitude)")
                    
                    let annotation = MKPointAnnotation()

                    annotation.coordinate = coordinate!
                    
                    DispatchQueue.main.async {
                        self.mapView.removeAnnotation(annotation)
                        self.mapView.addAnnotation(annotation)
                    }

                    
                } else {
                    self.showAlert("No matches")
                }
                
            }
            
            
            
        }
    }
    
    @IBAction func placePinButtonPressed(_ sender: UIButton) {
        // Add code
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapElements.isHidden = true
        
        // Form Background
        self.view.backgroundColor = setColour(alpha: 1.0)
        setUpBackground(formView)
        
        // Title
        titleLabel.font = UIFont(name: "Roboto-Medium", size: 26)
        
        // Textfields
        setupTextField(self, textField, hasPadding: false)
        
        // Login Button
        findButton.titleLabel?.font = UIFont(name: "Roboto-Medium", size: 20)
        findButton.backgroundColor = setColour(alpha: 1.0)
        
    }
    
    func setColour(alpha: CGFloat) -> UIColor {
        return UIColor(red: 0.956, green: 0.333, blue: 0.0, alpha: alpha)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.backgroundColor = UIColor.white
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.text?.isEmpty)! {
            textField.backgroundColor = setColour(alpha: 0.3)
        } else {
            textField.backgroundColor = UIColor.white
        }
    }
}
