//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by David Gibbs on 21/01/2017.
//  Copyright © 2017 SixtySticks. All rights reserved.
//

import Foundation

struct StudentLocation {
    
    var firstName: String?
    var lastName: String?
    var latitude: Double?
    var longitude: Double?
    var mapString: String?
    var mediaURL: String?
    var uniqueKey: String?
    
    init(dictionary: [String:AnyObject]) {
        self.firstName = dictionary["firstName"] as? String
        self.lastName = dictionary["lastName"]  as? String
        self.latitude = dictionary["latitude"]  as? Double
        self.longitude = dictionary["longitude"] as? Double
        self.mapString = dictionary["mapString"] as? String
        self.mediaURL = dictionary["mediaURL"]  as? String
        self.uniqueKey = dictionary["uniqueKey"] as? String
    }
    
}
