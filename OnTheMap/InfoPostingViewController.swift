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
    
    enum ViewOnDisplay {
        case FormView
        case MapView
        case LinkView
    }
    
    var posterLatitude: CLLocationDegrees? = nil
    var posterLongitude: CLLocationDegrees? = nil
    
    @IBOutlet weak var formTitleLabel: UILabel!
    @IBOutlet weak var formTextField: UITextField!
    @IBOutlet weak var formFindButton: UIButton!
    @IBOutlet weak var formView: UIView!
    
    @IBOutlet weak var mapTitleLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapViewButton: UIButton!
    @IBOutlet weak var mapWrapperView: UIView!
    
    @IBOutlet weak var linkTitleLabel: UILabel!
    @IBOutlet weak var linkViewTextField: UITextField!
    @IBOutlet weak var linkViewButton: UIButton!
    @IBOutlet weak var linkView: UIView!
    
    @IBAction func findButtonPressed(_ sender: UIButton) {
        
        self.view.endEditing(true)
        
        let geocoder = CLGeocoder()
        
        guard let place = formTextField.text else {
            self.showAlert("Please enter a location")
            return
        }
        
        geocoder.geocodeAddressString(place) { (placemarks, error) in
            
            if error != nil {
                self.showAlert("Can't find location")
            } else {
                self.displayView(.MapView)
                // Add spinner
                
                let placemark = placemarks?.first
                
                if let placemark = placemark {
                    let coordinate = placemark.location?.coordinate
                    print("Latitude: \(coordinate?.latitude) // Longitude: \(coordinate?.longitude)")
                    
                    let span = MKCoordinateSpanMake(0.05, 0.05)
                    let region = MKCoordinateRegion(center: coordinate!, span: span)
                    
                    let annotation = MKPointAnnotation()

                    annotation.coordinate = coordinate!
                    
                    self.posterLatitude = coordinate?.latitude
                    self.posterLongitude = coordinate?.longitude
                    
                    DispatchQueue.main.async {
                        self.mapView.removeAnnotation(annotation)
                        self.mapView.addAnnotation(annotation)
                        self.mapView.setRegion(region, animated: true)
                    }
                    
                } else {
                    self.showAlert("No matches for that location")
                }
            }
        }
    }
    
    @IBAction func placePinButtonPressed(_ sender: UIButton) {
        self.displayView(.LinkView)
    }
    
    @IBAction func linkViewButtonPressed(_ sender: UIButton) {
        ParseClient.sharedInstance().postStudentLocation(mapString: formTextField.text!, mediaUrl: linkViewTextField.text, latitude: posterLatitude!, longitude: posterLongitude!)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func displayView(_ viewToDisplay: ViewOnDisplay) {
        switch viewToDisplay {
        case .FormView:
            formView.isHidden = false
            mapWrapperView.isHidden = true
            linkView.isHidden = true
        case .MapView:
            formView.isHidden = true
            mapWrapperView.isHidden = false
            linkView.isHidden = true
        case .LinkView:
            formView.isHidden = true
            mapWrapperView.isHidden = true
            linkView.isHidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.displayView(.FormView)
        
        // Set up Background
        setUpBackground(self.view)
        
        // Set up title styles
        let font = UIFont(name: "Roboto-Medium", size: 24)
        formTitleLabel.font = font
        mapTitleLabel.font = font
        linkViewTextField.font = font
        
        // Set up textfields
        setupTextField(self, formTextField, hasPadding: false)
        setupTextField(self, linkViewTextField, hasPadding: false)
        
        // Set up buttons
        setupButton(formFindButton)
        setupButton(mapViewButton)
        setupButton(linkViewButton)
        
    }
    
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
            textField.backgroundColor = setColour(alpha: 0.3)
        } else {
            textField.backgroundColor = UIColor.white
        }
    }
}
