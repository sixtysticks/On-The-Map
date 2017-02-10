//
//  ListViewController.swift
//  OnTheMap
//
//  Created by David Gibbs on 23/01/2017.
//  Copyright © 2017 SixtySticks. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var locations = [StudentLocation]()
    
    @IBOutlet weak var studentTableView: UITableView!
    
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
        
        showActivitySpinner(activityViewSpinner, style: .gray)
        
        DispatchQueue.main.async {
            self.hideActivitySpinner(self.activityViewSpinner)
//            self.studentTableView.reloadData()
            self.fetchLocations()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityViewSpinner.isHidden = true
        
        fetchLocations()
    }
    
    func fetchLocations() {
        
        showActivitySpinner(activityViewSpinner, style: .gray)
        
        ParseClient.sharedInstance().getStudentLocations(completionHandlerForGetLocations: { (results, success, error) in
            if success {
                DispatchQueue.main.async {
                    self.hideActivitySpinner(self.activityViewSpinner)
                    self.studentTableView.reloadData()
                }
            }
        })
    }
    
    // MARK: Table View Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ParseClient.sharedInstance().locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentCell")!
        
        let student = ParseClient.sharedInstance().locations[indexPath.row]
        
        if let firstName = student.firstName, let lastName = student.lastName {
            let letters = NSCharacterSet.letters
            let cellText = "\(firstName) \(lastName)"
            let range = cellText.rangeOfCharacter(from: letters)
            
            if (range != nil) {
                cell.textLabel?.text = cellText
            }
            
        } else {
            cell.textLabel?.text = ParseConstants.NoName
        }
        
        if let mediaUrl = student.mediaURL {
            cell.detailTextLabel?.text = mediaUrl
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let app = UIApplication.shared
        let mediaUrl = ParseClient.sharedInstance().locations[indexPath.row].mediaURL
        
        if let toOpen = mediaUrl {
            if canVerifyUrl(urlString: toOpen) {
                app.open(URL(string: toOpen)!, options: [:], completionHandler: nil)
            } else {
                showAlert("The URL was not valid and could not be opened")
            }
        }
    }


}
