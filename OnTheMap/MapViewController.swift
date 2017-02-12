//
//  MapViewController.swift
//  OnTheMap
//
//  Created by David Gibbs on 10/01/2017.
//  Copyright © 2017 SixtySticks. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    var annotations = [MKPointAnnotation]()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityViewSpinner: UIActivityIndicatorView!
    
    @IBAction func logoutButtonPressed(_ sender: UIBarButtonItem) {
        
        showActivitySpinner(activityViewSpinner, style: .gray)
        
        UdacityClient.sharedInstance().endUserSession { (success, error) in
            if success {
                self.tabBarController?.dismiss(animated: true, completion: nil)
            } else {
                self.showAlert(error!)
            }
            
            DispatchQueue.main.async {
                self.hideActivitySpinner(self.activityViewSpinner)
            }
        }
    }
    
    @IBAction func refreshButtonPressed(_ sender: UIBarButtonItem) {
        
        showActivitySpinner(self.activityViewSpinner, style: .gray)
        
        DispatchQueue.main.async {
            self.populateMap()
            self.hideActivitySpinner(self.activityViewSpinner)
        }
        
    }
    
    func populateMap() {
        
        ParseClient.sharedInstance().displayStudentLocations() { (locations, success, error) in
            
            if success {
                for location in locations! {
                    if let lat = location.latitude, let long = location.longitude,
                        let firstName = location.firstName, let lastName = location.lastName,
                        let mediaURL =  location.mediaURL {
                        
                        let annotation = MKPointAnnotation()
                        
                        let latDegrees = CLLocationDegrees(lat)
                        let longDegrees = CLLocationDegrees(long)
                        let coordinate = CLLocationCoordinate2D(latitude: latDegrees, longitude: longDegrees)
                        
                        annotation.coordinate = coordinate
                        
                        annotation.title = "\(firstName) \(lastName)"
                        
                        if mediaURL.isEmpty {
                            annotation.subtitle = ParseConstants.DefaultURL
                        } else {
                            annotation.subtitle = mediaURL
                        }
                        
                        self.annotations.append(annotation)
                    }
                }
                
                DispatchQueue.main.async {
                    self.mapView.removeAnnotations(self.annotations)
                    self.mapView.addAnnotations(self.annotations)
                }
                
            } else {
                self.showAlert(error!)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        DispatchQueue.main.async {
            self.populateMap()
        }
        
        activityViewSpinner.isHidden = true
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            
            if let toOpen = view.annotation?.subtitle {
                if canVerifyUrl(urlString: toOpen) {
                    app.open(URL(string: toOpen!)!, options: [:], completionHandler: nil)
                } else {
                    showAlert("The URL was not valid and could not be opened")
                }
            }
        }
    }
}
