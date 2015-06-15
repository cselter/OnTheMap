//
//  OTMclient.swift
//  OnTheMap
//
//  Created by Christopher Burgess on 6/5/15.
//  Copyright (c) 2015 Christopher Burgess. All rights reserved.
//

import Foundation
import MapKit

class OTMclient : NSObject {
     
     /* Shared session */
     var session: NSURLSession
     
     static let UdacityLoginURL : String = "https://www.udacity.com/api/session"
     static let UdacityStudentDataURL : String = "https://www.udacity.com/api/users/"
     static let ParseStudentLocationDataURL : String = "https://api.parse.com/1/classes/StudentLocation"
     static let ParseAppID : String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
     static let ParseAPI : String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
     
     override init() {
          session = NSURLSession.sharedSession()
          super.init()
     }
     
     var appDelegate:AppDelegate!
     
     // *************************************
     // * Login to Udacity to get sessionID *
     // *************************************
     func loginToUdacity(udacityLogin: String, password: String, completionHandler: (success: Bool, data: [String: AnyObject]?, errorString: String?) -> Void) {
          
          // Test for network connectivity
          dispatch_async(dispatch_get_main_queue()) {
               if Network.isConnectedToNetwork() == false {
                    completionHandler(success: false, data: nil, errorString: "No Network Connectivity")
                    return
               }
          }
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
                    
                    // first check if parse was successful
                    if let parsedError = parsedResult["error"] as? String {
                         println("OTMclient: parse error")
                         completionHandler(success: false, data: nil, errorString: parsedError)
                    } else {
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
                                             completionHandler(success: true, data: udacityDictionary, errorString: nil)
                                        } else {
                                             completionHandler(success: false, data: nil, errorString: "OTMclient: User not registered.")
                                        }
                                   } else {
                                        completionHandler(success: false, data: nil, errorString: "OTMclient: User not registered.")
                                   }
                              } else {
                                   completionHandler(success: false, data: nil, errorString: "OTMclient: User not registered.")
                              }
                         } else {
                              completionHandler(success: false, data: nil, errorString: "OTMclient: Account data not found.")
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
               
               // first check if parse was successful
               if let parsedError = parsedResult["error"] as? String {
                    println("OTMclient: student data raw parse error")
               } else {
                    // println("student data raw parse success")
                    if let studentData = parsedResult["user"] as? [String: AnyObject] {
                         if let firstName = studentData["first_name"] as? String {
                              if let lastName = studentData["last_name"] as? String {
                                   let nameUpdateDictionary : [String: AnyObject] =
                                   ["firstName" : firstName,
                                        "lastName" : lastName]
                                   completionHandler(data: nameUpdateDictionary, errorString: nil)
                              }
                         }else {
                              completionHandler(data: nil, errorString: "Couldn't get user's name")
                         }
                    } else {
                         completionHandler(data: nil, errorString: "Couldn't get user's data")
                    }
               }
          }
          
          task.resume()
     }
     
     // *********************
     // * Logout of Udacity *
     // *********************
     func logoutOfUdacity () {
          let request = NSMutableURLRequest(URL: NSURL(string: OTMclient.UdacityLoginURL)!)
          request.HTTPMethod = "DELETE"
          var xsrfCookie: NSHTTPCookie? = nil
          let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
          for cookie in sharedCookieStorage.cookies as! [NSHTTPCookie] {
               if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
          }
          if let xsrfCookie = xsrfCookie {
               request.addValue(xsrfCookie.value!, forHTTPHeaderField: "X-XSRF-Token")
          }
          let session = NSURLSession.sharedSession()
          let task = session.dataTaskWithRequest(request) { data, response, error in
               if error != nil { // Handle error…
                    return
               }
               
               let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
               println(NSString(data: newData, encoding: NSUTF8StringEncoding))
               
          }
          task.resume()
     }

     // ***********************************************
     // * Login to Parse to get Student Location Data *
     // ***********************************************
     func getStudentLocations(completionHandler: (data: [[String: AnyObject]]?, errorString: String?) -> Void){     
          let methodParameters = [
               "order": "-createdAt,-updatedAt",
               "limit": 100,
          ]
          
          let parseRequest = NSMutableURLRequest(URL: NSURL(string: OTMclient.ParseStudentLocationDataURL + OTMclient.escapedParameters(methodParameters))!)
          parseRequest.addValue("\(OTMclient.ParseAppID)", forHTTPHeaderField: "X-Parse-Application-Id")
          parseRequest.addValue("\(OTMclient.ParseAPI)", forHTTPHeaderField: "X-Parse-REST-API-Key")
          let session = NSURLSession.sharedSession()
          let task = session.dataTaskWithRequest(parseRequest) { data, response, error in
               if error != nil { // If request errors
                    completionHandler(data: nil, errorString: error!.localizedDescription)
                    return
               } // otherwise, use data
               
               var parsingError: NSError? = nil
               
               let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
               
               if parsingError != nil {
                    completionHandler(data: nil, errorString: "Unable to load students data")
               } else {
                    if let students = parsedResult["results"] as? [[String: AnyObject]] {
                         completionHandler(data: students, errorString: nil)
                    }
               }
          }
          task.resume()
     }
     
     // **************************************
     // * Post Student Location to Parse API *
     // **************************************
     func postStudentLocation(enteredURL: String, lat: CLLocationDegrees, long: CLLocationDegrees, mapString: String, completionHandler: (success: Bool?) -> Void) {
          self.appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
          let studentKey = self.appDelegate.loggedInStudent?.studentKey
          let fName = self.appDelegate.loggedInStudent?.firstName
          let lName = self.appDelegate.loggedInStudent?.lastName
          let latLoc = lat
          let longLoc = long
          let mString = mapString
          
          let request = NSMutableURLRequest(URL: NSURL(string: OTMclient.ParseStudentLocationDataURL)!)
          request.HTTPMethod = "POST"
          request.addValue("\(OTMclient.ParseAppID)", forHTTPHeaderField: "X-Parse-Application-Id")
          request.addValue("\(OTMclient.ParseAPI)", forHTTPHeaderField: "X-Parse-REST-API-Key")
          request.addValue("application/json", forHTTPHeaderField: "Content-Type")
          request.HTTPBody = "{\"uniqueKey\": \"\(studentKey!)\", \"firstName\": \"\(fName!)\", \"lastName\": \"\(lName!)\",\"mapString\": \"\(mString)\", \"mediaURL\": \"\(mString)\",\"latitude\": \(latLoc), \"longitude\": \(longLoc)}".dataUsingEncoding(NSUTF8StringEncoding)
          
          let session = NSURLSession.sharedSession()
          let task = session.dataTaskWithRequest(request) { data, response, error in
               if error != nil { // Handle error…
                    println(error)
                    // Unable to post location
                    var invalidAddress = UIAlertView()
                    invalidAddress.title = "Unable to post location"
                    invalidAddress.message = "Please try again later."
                    invalidAddress.addButtonWithTitle("OK")
                    invalidAddress.show()
                    completionHandler(success:false)
                    return
               }
               completionHandler(success: true)
          }
          task.resume()
     }
     
     // **********************************************
     // * Check to see if student has already posted *
     // **********************************************
     func queryForStudentLocation(completionHandler: (data: [[String: AnyObject]]?, errorString: String?) -> Void) {
          appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
          let studentKey = self.appDelegate.loggedInStudent?.studentKey
          
          let urlString = "https://api.parse.com/1/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22\(studentKey!)%22%7D"
          let url = NSURL(string: urlString)
          let request = NSMutableURLRequest(URL: url!)
          request.addValue("\(OTMclient.ParseAppID)", forHTTPHeaderField: "X-Parse-Application-Id")
          request.addValue("\(OTMclient.ParseAPI)", forHTTPHeaderField: "X-Parse-REST-API-Key")
          let session = NSURLSession.sharedSession()
          let task = session.dataTaskWithRequest(request) { data, response, error in
               if error != nil {
                    println(error)
                    completionHandler(data: nil, errorString: error.localizedDescription)
                    /* Handle error */
                    return
               }
               
               // use the data
               var parsingError: NSError? = nil
               
               let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
               
               if parsingError != nil {
                    completionHandler(data: nil, errorString: "Unable to load students data")
               } else {
                    if let locations = parsedResult["results"] as? [[String: AnyObject]] {
                         completionHandler(data: locations, errorString: nil)
                    }
               }
          }
          task.resume()
     }
     
     // *************************
     // * Delete existing posts *
     // *************************
     func deleteExistingPosts(data: [[String: AnyObject]]) {

          var locArr: [[String:AnyObject]] = [[String:AnyObject]]()
     
          for loc in data {
               locArr.append(loc)
               let objID = loc["objectId"] as? String

               let urlString = "https://api.parse.com/1/classes/StudentLocation/\(objID!)"
               let url = NSURL(string: urlString)
               let request = NSMutableURLRequest(URL: url!)
               request.HTTPMethod = "DELETE"
               request.addValue("\(OTMclient.ParseAppID)", forHTTPHeaderField: "X-Parse-Application-Id")
               request.addValue("\(OTMclient.ParseAPI)", forHTTPHeaderField: "X-Parse-REST-API-Key")
               request.addValue("application/json", forHTTPHeaderField: "Content-Type")
               
               let session = NSURLSession.sharedSession()
               let task = session.dataTaskWithRequest(request) { data, response, error in
                    if error != nil { // Handle error…
                         println("unable to delete")
                         return
                    }
               }
               task.resume()
          }
     }
     
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