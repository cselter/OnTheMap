//
//  Student.swift
//  OnTheMap
//
//  Created by Christopher Burgess on 6/7/15.
//  Copyright (c) 2015 Christopher Burgess. All rights reserved.
//

import Foundation

struct Student {

     var firstName: String?
     var lastName: String?
     var studentKey: String?
     var studentURL: String? // from Udacity profile
     var mediaURL: String? // from Parse API
     var latitude: Float?
     var longitude: Float?

     init(studentData: [String: AnyObject]?) {
          
          if let studentData = studentData {
               if let studentKey = studentData["studentKey"] as? String {
                    self.studentKey = studentKey
               }
               
               if let firstName = studentData["firstName"] as? String {
                    self.firstName = firstName
               }
               
               if let lastName = studentData["lastName"] as? String {
                    self.lastName = lastName
               }
               
               if let studentURL = studentData["studentURL"] as? String {
                    self.studentURL = studentURL
               }
               
               if let mediaURL = studentData["mediaURL"] as? String {
                    self.mediaURL = mediaURL
               }
               
               if let latitude = studentData["latitude"] as? Float {
                    self.latitude = latitude
               }

               if let longitude = studentData["longitude"] as? Float {
                    self.longitude = longitude
               } 
          }
     }
}
