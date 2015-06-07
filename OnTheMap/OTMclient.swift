//
//  OTMclient.swift
//  OnTheMap
//
//  Created by Christopher Burgess on 6/5/15.
//  Copyright (c) 2015 Christopher Burgess. All rights reserved.
//

import Foundation

class OTMclient : NSObject {
     
     /* Shared session */
     var session: NSURLSession
     
     static let UdacityLoginURL : String = "https://www.udacity.com/api/session"
     static let UdacityStudentDataURL : String = "https://www.udacity.com/api/users/"
     
     var username: String? = nil // DO I NEED THIS?
     var sessionID : String? = nil // DO I NEED THIS?
     
     override init() {
          session = NSURLSession.sharedSession()
          super.init()
     }
     
     // *************************************
     // * Login to Udacity to get sessionID *
     // *************************************
     func loginToUdacity(udacityLogin: String, password: String, completionHandler: (success: Bool, data: [String: AnyObject]?, errorString: String?) -> Void) {
          
          // set up the request
          let request = NSMutableURLRequest(URL: NSURL(string: OTMclient.UdacityLoginURL)!)
          request.HTTPMethod = "POST"
          request.addValue("application/json", forHTTPHeaderField: "Accept")
          request.addValue("application/json", forHTTPHeaderField: "Content-Type")
          request.HTTPBody = "{\"udacity\": {\"username\": \"\(udacityLogin)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
          
          let session = NSURLSession.sharedSession()
          let task = session.dataTaskWithRequest(request) { data, response, error in
               if error != nil { // Send error back through completion handler
                    completionHandler(success: false, data: nil, errorString: error.localizedDescription)
               }
               else { // Parse and use the data
                    let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
                    
                    var parsingError: NSError? = nil
          
                    let parsedResult = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                    
                    println(parsedResult)
                    
                    // first check if parse was successful
                    if let parsedError = parsedResult["error"] as? String {
                         println("parse error")
                         completionHandler(success: false, data: nil, errorString: parsedError)
                    } else {
                         println("parse success")
                         if let accountData = parsedResult["account"] as? [String: AnyObject] {
                              // review account data
                              if let isRegistered = accountData["registered"] as? Bool {
                                   if isRegistered {
                                        // user has account
                                        if let key = accountData["key"] as? String {
                                             let udacityDictionary: [String: AnyObject] = [
                                                  "studentKey" : key,
                                                  "registered" : isRegistered
                                             ]
                                             println(key)
                                             completionHandler(success: true, data: udacityDictionary, errorString: nil)
                                        } else {
                                             completionHandler(success: false, data: nil, errorString: "ERROR0")
                                        }
                                   } else {
                                        completionHandler(success: false, data: nil, errorString: "ERROR1")
                                   }
                              } else {
                                   completionHandler(success: false, data: nil, errorString: "ERROR2")
                              }
                         } else {
                              completionHandler(success: false, data: nil, errorString: "ERROR3")
                         }
                    }
               }
          }
          
          task.resume()
     }
  

     // *************************************
     // * Get Logged In Student (User) Data *
     // *************************************
     func getUdacityStudentData(studentKey: String, completionHandler: (data: [String: AnyObject]?, errorString: String?) -> Void) {
          
          
          let request = NSMutableURLRequest(URL: NSURL(string: OTMclient.UdacityStudentDataURL + studentKey)!)
          
          let session = NSURLSession.sharedSession()
          
          let task = session.dataTaskWithRequest(request) {
               data, response, error in
               
               // if data session fails, return error
               if error != nil {
                    completionHandler(data: nil, errorString: error!.localizedDescription)
                    return
               }
               
               let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
               
               var parsingError: NSError? = nil
               
               let parsedResult = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
               
               println(parsedResult)
               
               
               
          }
          
          
          
          
          
          
          task.resume()
     }
     
     // *********************
     // * Logout of Udacity *
     // *********************
     func logoutUdacitySession () {
          
          // TODO: COMPLETE THIS

     }

     // TODO: MIGHT NOT NEED THIS vvvvvvvvvv - DOUBlE CHECK!
     /* Helper function: Given a dictionary of parameters, convert to a string for a url */
     class func escapedParameters(parameters: [String : AnyObject]) -> String {
          
          var urlVars = [String]()
          
          for (key, value) in parameters {
               
               /* Make sure that it is a string value */
               let stringValue = "\(value)"
               
               /* Escape it */
               let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
               
               /* Append it */
               urlVars += [key + "=" + "\(escapedValue!)"]
               
          }
          
          return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
     }
     
     // MARK: - Shared Instance
     class func sharedInstance() -> OTMclient {
          
          struct Singleton {
               static var sharedInstance = OTMclient()
          }
          
          return Singleton.sharedInstance
     }






}