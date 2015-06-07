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
     var studentURL: String?
     
     
     
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
               
               
               
          }
          
     }
     
}
