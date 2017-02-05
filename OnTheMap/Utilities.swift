//
//  Utilities.swift
//  OnTheMap
//
//  Created by David Gibbs on 17/01/2017.
//  Copyright © 2017 SixtySticks. All rights reserved.
//

import Foundation

final class Utilities {
    static let shared = Utilities()
    
    func handleErrors(_ data: Data?, _ response: URLResponse?, _ error: NSError?, completionHandler: @escaping (_ result: [String:AnyObject]?, _ success: Bool, _ error: String?) -> Void) {
        
        guard (error == nil) else {
            completionHandler(nil, false, "There was an error with your request")
            return
        }
        
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
            completionHandler(nil, false, "Your request returned an invalid status code other than 2xx")
            return
        }
        
        guard let _ = data else {
            completionHandler(nil, false, "No data was returned by the request")
            return
        }
    }
}
