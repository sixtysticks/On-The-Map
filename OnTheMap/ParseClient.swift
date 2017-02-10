//
//  ParseClient.swift
//  OnTheMap
//
//  Created by David Gibbs on 16/01/2017.
//  Copyright © 2017 SixtySticks. All rights reserved.
//

import Foundation

class ParseClient: NSObject {
    
    var locations = [StudentLocation]()
    var locationsFetched: Bool = false
    
    // MARK: Shared Instance
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
    
    func getStudentLocations(completionHandlerForGetLocations: @escaping (_ result: [String:AnyObject]?, _ success: Bool, _ error: String?) -> Void) {
        
        let request = NSMutableURLRequest(url: URL(string: "\(ParseConstants.ApiUrl)/\(ParseConstants.StudentLocation)\(ParseConstants.Limit)")!)
        request.addValue(ParseConstants.AppId, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(ParseConstants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let session = UdacityClient.sharedSession
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            Utilities.shared.handleErrors(data, response, error as NSError?, completionHandler: completionHandlerForGetLocations)
            
            self.parseData(data!, completionHandlerForConvertedData: completionHandlerForGetLocations)
            
        }
        task.resume()
    }
    
    func postStudentLocation(mapString: String, mediaUrl: String, latitude: Double, longitude: Double, completionHandlerForPostLocation: @escaping (_ result: [String:AnyObject]?, _ success: Bool, _ error: String?) -> Void) {
        
        let request = NSMutableURLRequest(url: URL(string: "\(ParseConstants.ApiUrl)/\(ParseConstants.StudentLocation)")!)
        request.httpMethod = "POST"
        request.addValue(ParseConstants.AppId, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(ParseConstants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonDict: [String:Any] = [
            "uniqueKey": UdacityClient.accountID!,
            "firstName": UdacityClient.firstName!,
            "lastname": UdacityClient.lastName!,
            "mapString": mapString,
            "mediaURL": mediaUrl,
            "latitude": latitude,
            "longitude": longitude
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonDict, options: .prettyPrinted)
        request.httpBody = jsonData
        
        let session = UdacityClient.sharedSession
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            Utilities.shared.handleErrors(data, response, error as NSError?, completionHandler: completionHandlerForPostLocation)
            
            // Parse and use the data
            self.parseData(data!, completionHandlerForConvertedData: completionHandlerForPostLocation)

        }
        task.resume()
    }
    
    func displayAnnotations(_ completionHandlerForAnnotations: @escaping (_ result: [StudentLocation]?, _ success: Bool, _ error: String?) -> Void) {
        
        ParseClient.sharedInstance().getStudentLocations { (results, success, error) in
            if success {
                if let data = results!["results"] as AnyObject? {
                    for result in data as! [AnyObject] {
                        let student = StudentLocation(dictionary: result as! [String : AnyObject])
                        self.locations.append(student)
                    }
                    self.locationsFetched = true
                    completionHandlerForAnnotations(self.locations, true, nil)
                }
            } else {
                completionHandlerForAnnotations(nil, false, error)
            }
        }
    }
    
    func parseData(_ data: Data, completionHandlerForConvertedData: (_ result: [String:AnyObject]?, _ success: Bool, _ error: String?) -> Void) {
        
        // Parse the raw JSON data
        let parsedResult: AnyObject!
        
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject!
        } catch {
            completionHandlerForConvertedData(nil, false, "There was an error parsing the JSON")
            return
        }
        completionHandlerForConvertedData(parsedResult as? [String:AnyObject], true, nil)
    }
}
