//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by David Gibbs on 04/01/2017.
//  Copyright © 2017 SixtySticks. All rights reserved.
//

import Foundation

class UdacityClient: NSObject {

    static var sharedSession = URLSession.shared
    
    // MARK: Stored variables
    static var sessionID: String? = nil
    static var accountID: String? = nil
    static var firstName: String? = nil
    static var lastName: String? = nil
    
    // MARK: Shared Instance
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
    
    // MARK: User authentication on login
    func authenticateUser(username: String, password: String, completionHandlerForAuth: @escaping (_ success: Bool, _ error: String?) -> Void) {
        
        let _ = createSession(UdacityConstants.ApiScheme + UdacityConstants.ApiSessionUrl, username: username, password: password) { (result, success, error) in
            
            guard let _ = result else {
                completionHandlerForAuth(false, UdacityConstants.NetworkProblems)
                return
            }
            
            guard let session = result?["session"], let sessionID = session["id"] as? String, let account = result?["account"], let accountID = account["key"] as? String else {
                print("Error getting session from result")
                completionHandlerForAuth(false, UdacityConstants.IncorrectDetails)
                return
            }
            
            // Store the IDs
            UdacityClient.sessionID = sessionID
            UdacityClient.accountID = accountID
            
            let _ = self.getPublicUserData(completionHandlerForPublicData: { (result, success, error) in
                
                guard let user = result?["user"] else {
                    print("Error getting user from result")
                    return
                }
                
                guard let firstName = user["first_name"] as? String, let lastName = user["last_name"] as? String else {
                    print("Error getting name from result")
                    return
                }
                
                // Store the user's name for later use
                UdacityClient.firstName = firstName as String?
                UdacityClient.lastName = lastName as String?
            })
            
            completionHandlerForAuth(true, nil)
        }
    }
    
    // MARK: Get the user data needed to post to the app
    func getPublicUserData(completionHandlerForPublicData: @escaping (_ result: [String:AnyObject]?, _ success: Bool, _ error: String?) -> Void) {
        
        let request = NSMutableURLRequest(url: URL(string: "\(UdacityConstants.ApiUserIdUrl)\(UdacityClient.accountID!)")!)
        
        let task = UdacityClient.sharedSession.dataTask(with: request as URLRequest) { data, response, error in
            
            guard let _ = data else {
                completionHandlerForPublicData(nil, false, UdacityConstants.NetworkProblems)
                return
            }
            
            Utilities.shared.handleErrors(data, response, error as NSError?, completionHandler: completionHandlerForPublicData)
            
            // Remove first five numbers of data
            let newData = data?.subdata(in: Range(uncheckedBounds: (5, data!.count)))
            
            // Parse and use the data
            self.convertDataWithCompletionHandler(newData!, completionHandlerForConvertedData: completionHandlerForPublicData)
        }
        task.resume()
    }
    
    // MARK: Create a session in which to use the app
    func createSession(_ url_path: String, username: String, password: String, completionHandlerForPOST: @escaping (_ result: [String:AnyObject]?, _ success: Bool, _ error: String?) -> Void) -> URLSessionDataTask {
        
        let request = NSMutableURLRequest(url: URL(string: url_path)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonDict: [String: Any] = [
            "udacity": [
                "username": username,
                "password": password
            ]
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonDict, options: .prettyPrinted)
        request.httpBody = jsonData
        
        let task = UdacityClient.sharedSession.dataTask(with: request as URLRequest) { data, response, error in
            
            guard let _ = data else {
                Utilities.shared.handleErrors(data, response, error as NSError?, completionHandler: completionHandlerForPOST)
                return
            }
            
            // Remove first five numbers of data
            let newData = data?.subdata(in: Range(uncheckedBounds: (5, data!.count)))
            
            // Parse and use the data
            self.convertDataWithCompletionHandler(newData!, completionHandlerForConvertedData: completionHandlerForPOST)
            
        }
        task.resume()
        
        return task
    }
    
    // MARK: Destroy the session on logout
    func endUserSession(completionHandlerForDeleteSession: @escaping (_ success: Bool, _ error: String?) -> Void) {
        let _ = deleteSession { (result, success, error) in
            if success {
                completionHandlerForDeleteSession(true, nil)
            } else {
                completionHandlerForDeleteSession(false, error)
            }
        }
    }
    
    func deleteSession(completionHandlerForDELETE: @escaping (_ result: [String:AnyObject]?, _ success: Bool, _ error: String?) -> Void) -> URLSessionDataTask {
        
        // Make network request
        let request = NSMutableURLRequest(url: URL(string: UdacityConstants.ApiScheme + UdacityConstants.ApiSessionUrl)!)
        request.httpMethod = "DELETE"
        
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let task = UdacityClient.sharedSession.dataTask(with: request as URLRequest) { data, response, error in
            
            guard let _ = data else {
                Utilities.shared.handleErrors(data, response, error as NSError?, completionHandler: completionHandlerForDELETE)
                return
            }
            
            Utilities.shared.handleErrors(data, response, error as NSError?, completionHandler: completionHandlerForDELETE)
            
            // Remove first five numbers of data
            let newData = data?.subdata(in: Range(uncheckedBounds: (5, data!.count)))
            
            // Parse and use the data
            self.convertDataWithCompletionHandler(newData!, completionHandlerForConvertedData: completionHandlerForDELETE)
        }
        task.resume()
        
        return task
    }
    
    // MARK: Parse the raw JSON data accordingly
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertedData: (_ result: [String:AnyObject]?, _ success: Bool, _ error: String?) -> Void) {
        
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
