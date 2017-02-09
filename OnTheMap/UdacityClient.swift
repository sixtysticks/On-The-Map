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
    
    // MARK: Custom model methods
    
    func authenticateUser(username: String, password: String, completionHandlerForAuth: @escaping (_ success: Bool, _ error: String?) -> Void) {
        
        let _ = createSession(UdacityConstants.ApiScheme + UdacityConstants.ApiSessionUrl, username: username, password: password) { (result, success, error) in
            
            if success {
                guard let session = result?["session"], let sessionID = session["id"] as? String else {
                    print("Error getting session from result")
                    return
                }
                
                guard let account = result?["account"], let accountID = account["key"] as? String else {
                    print("Error getting account id from result")
                    return
                }
                
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
                    
                    UdacityClient.firstName = firstName as String?
                    UdacityClient.lastName = lastName as String?
                })
                
                
                completionHandlerForAuth(true, nil)
                
            } else {
                completionHandlerForAuth(false, error)
            }
        }
    }
    
    func getPublicUserData(completionHandlerForPublicData: @escaping (_ result: [String:AnyObject]?, _ success: Bool, _ error: String?) -> Void) {
        
        let request = NSMutableURLRequest(url: URL(string: "\(UdacityConstants.ApiUserIdUrl)\(UdacityClient.accountID!)")!)
        
        let task = UdacityClient.sharedSession.dataTask(with: request as URLRequest) { data, response, error in
            
            Utilities.shared.handleErrors(data, response, error as NSError?, completionHandler: completionHandlerForPublicData)
            
            // Remove first five numbers of data
            let newData = data?.subdata(in: Range(uncheckedBounds: (5, data!.count)))
            
            // print("NEW_DATA: \(NSString(data: newData!, encoding: String.Encoding.utf8.rawValue)!)")
            
            // Parse and use the data
            self.convertDataWithCompletionHandler(newData!, completionHandlerForConvertedData: completionHandlerForPublicData)
        }
        task.resume()
    }
    
    func createSession(_ url_path: String, username: String, password: String, completionHandlerForPOST: @escaping (_ result: [String:AnyObject]?, _ success: Bool, _ error: String?) -> Void) -> URLSessionDataTask {
        
        // Make network request
        
        let request = NSMutableURLRequest(url: URL(string: url_path)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".data(using: String.Encoding.utf8)
        
        // Create a session ID
        let task = UdacityClient.sharedSession.dataTask(with: request as URLRequest) { data, response, error in
            
            Utilities.shared.handleErrors(data, response, error as NSError?, completionHandler: completionHandlerForPOST)
            
            // Remove first five numbers of data
            let newData = data?.subdata(in: Range(uncheckedBounds: (5, data!.count)))
            
            // Parse and use the data
            self.convertDataWithCompletionHandler(newData!, completionHandlerForConvertedData: completionHandlerForPOST)
            
        }
        task.resume()
        
        return task
    }
    
    func endUserSession(completionHandlerForDeleteSession: @escaping (_ success: Bool, _ error: String?) -> Void) {
        let _ = deleteSession { (result, success, error) in
            if success {
                guard let session = result?["session"], let id = session["id"] else {
                    print("Error deleting session")
                    return
                }
                
                print("session_id: \(id)")
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
            
            Utilities.shared.handleErrors(data, response, error as NSError?, completionHandler: completionHandlerForDELETE)
            
            // Remove first five numbers of data
            let newData = data?.subdata(in: Range(uncheckedBounds: (5, data!.count)))
            
            // Parse and use the data
            self.convertDataWithCompletionHandler(newData!, completionHandlerForConvertedData: completionHandlerForDELETE)
        }
        task.resume()
        
        return task
    }
    
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
