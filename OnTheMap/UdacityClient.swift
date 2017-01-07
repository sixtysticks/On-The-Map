//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by David Gibbs on 04/01/2017.
//  Copyright © 2017 SixtySticks. All rights reserved.
//

import Foundation

class UdacityClient: NSObject {

    var sharedSession = URLSession.shared
    var sessionID : String? = nil
    
    // MARK: Constants
    struct Constants {
        static let ApiScheme = "https://"
        static let ApiHost = "www.udacity.com/api/session"
    }
    
    func authenticateUser(username: String, password: String, completionHandlerForAuth: @escaping (_ success: Bool, _ error: String?) -> Void) {
        
        getSessionID(username: username, password: password) { (success, sessionID, error) in
            
            if success {
                print("SESSION ID: \(sessionID)")
                self.sessionID = sessionID
            } else {
                completionHandlerForAuth(false, "Error getting session ID (getSessionID)")
            }
        }
    }
    
    func getSessionID(username: String, password: String, completionHandlerForSession: @escaping (_ success: Bool, _ sessionID: String?, _ error: String?) -> Void) {
        let _ = taskForGET(Constants.ApiScheme + Constants.ApiHost, username: username, password: password) { (result, success, error) in
            if let error = error {
                print(error)
                completionHandlerForSession(false, nil, "Login Failed (getSessionID).")
            } else {
                // GRAB SESSION ID
            }
        }
    }
    
    func taskForGET(_ url_path: String, username: String, password: String, completionHandlerForGET: @escaping (_ result: AnyObject?, _ success: Bool, _ error: String?) -> Void) -> URLSessionDataTask {
        
        // Step 1: Make request
        
        let request = NSMutableURLRequest(url: URL(string: url_path)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".data(using: String.Encoding.utf8)
        
        print("\(request)")
        
        // Step 2: Create a session ID
        
        let task = sharedSession.dataTask(with: request as URLRequest) { data, response, error in
            func sendError(_ error: String) {
                print(error)
            }
            
            // GUARD: Was there an error?
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            // GUARD: Did we get a successful 2XX response?
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            // GUARD: Was there any data returned?
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            // Parse the data and use the data
             self.convertDataWithCompletionHandler(data, completionHandlerForConvertedData: completionHandlerForGET)
            
        }
        task.resume()
        
        return task
    }
    
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertedData: (_ result: AnyObject?, _ success: Bool, _ error: String?) -> Void) {
        
        // Parse the raw JSON data
        let parsedResult: AnyObject!
        
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject!
        } catch {
            completionHandlerForConvertedData(nil, false, "There was an error parsing the JSON")
            return
        }

        completionHandlerForConvertedData(parsedResult as AnyObject?, true, nil)
    }
    
    // MARK: Shared Instance
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }

}
