//
//  StudentInfoViewController.swift
//  OnTheMap
//
//  Created by Christopher Burgess on 6/6/15.
//  Copyright (c) 2015 Christopher Burgess. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class StudentInfoViewController: UIViewController {
     
     @IBOutlet weak var nameLabel: UILabel!
     @IBOutlet weak var studentKey: UILabel!
     @IBOutlet weak var mediaURLLabel: UILabel!
     @IBOutlet weak var latLabel: UILabel!
     @IBOutlet weak var longLabel: UILabel!
     @IBOutlet weak var mapView: MKMapView!
 
     
     var appDelegate: AppDelegate!
     var userfName: String?
     var userlName: String?
     var userKey: String?
     var lat: Double?
     var long: Double?
     var loc: CLPlacemark?
     var mediaURL: String?
     let client = OTMclient.sharedInstance()
     
     override func viewDidLoad() {
          super.viewDidLoad()
          appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
     }
     
     override func viewDidAppear(animated: Bool) {
          // Refreshes this page each time it is viewed with current info
          // from the appDelegate
          updateStudentInfoLabels()
          checkForExistingLocation()
     }
     
     @IBAction func refreshButtonTouchUp(sender: AnyObject) {
          checkForExistingLocation()
     }
     
     // ***************************************
     // * Query for existing student location *
     // ***************************************
     func checkForExistingLocation() {
          client.queryForStudentLocation() {
               data, error in
               
               if error == nil { // if no error
                    if let data = data { // and data is not nil
                         if data.count > 0 { // and count of objects is >0
                              // existing posts found
                              // zoom to existing pin
                              
                              var existingLat: Double = data[0]["latitude"] as! Double
                              var existingLong: Double = data[0]["longitude"] as! Double
                              
                              // update the variables
                              self.lat = existingLat
                              self.long = existingLong
                              self.mediaURL = data[0]["mediaURL"] as? String
                              
                              // update the appDelegate
                              self.appDelegate.loggedInStudent?.latitude = self.lat
                              self.appDelegate.loggedInStudent?.longitude = self.long
                              self.appDelegate.loggedInStudent?.mediaURL = self.mediaURL
                              
                              dispatch_async(dispatch_get_main_queue()) {
                                   self.latLabel.text = self.appDelegate.loggedInStudent?.latitude?.description
                                   
                                   self.longLabel.text = self.appDelegate.loggedInStudent?.longitude?.description
                                   
                                   self.mediaURLLabel.text = self.appDelegate.loggedInStudent?.mediaURL
                              }
                              var latCord: CLLocationDegrees = existingLat
                              var longCord: CLLocationDegrees = existingLong
                              
                              let existingLoc = CLLocationCoordinate2DMake(latCord, longCord)
                              
                              self.addPinsAndZoom()
                         }
                    }
               }
          }
     }
     
     // ****************************************************
     // * Post new student location, checking for existing *
     // ****************************************************
     @IBAction func locationButtonTouchUp(sender: AnyObject) {
          let client = OTMclient.sharedInstance()
          client.queryForStudentLocation() {
               data, error in
               
               if error == nil { // if no error
                    if let data = data { // and data is not nil
                         if data.count > 0 { // and count of objects is >0
                              // alert the user of the existing location pin
                              var alert = UIAlertController(title: "Existing Pin", message: "You've already posted your location.", preferredStyle: UIAlertControllerStyle.ActionSheet)
                              
                              alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { action in
                                   
                              }))
                              
                              alert.addAction(UIAlertAction(title: "Delete & Post New", style: .Default, handler: { action in
                                   client.deleteExistingPosts(data)
                                   // Segue to Location Entry
                                   self.performSegueWithIdentifier("OpenLocationSelectVCfromStudInfo", sender: self)
                              }))
                              
                              self.presentViewController(alert, animated: true, completion: nil)
                         } else {
                              self.performSegueWithIdentifier("OpenLocationSelectVCfromStudInfo", sender: self)
                         }
                    }
               } else {
                    println("unable to query existing posts")
               }
          }
     }
     
     // **************************************
     // * Update the labels from AppDelegate *
     // **************************************
     func updateStudentInfoLabels() {
          
          // update View's Udacity Student Info
          if let userName = appDelegate.loggedInStudent?.firstName {
               userfName = userName
          } else {
               userfName = "unavail"
          }
          
          if let userName = appDelegate.loggedInStudent?.lastName {
               userlName = userName
          } else {
               userlName = "unavail"
          }
          
          if let key = appDelegate.loggedInStudent?.studentKey {
               userKey = key
          } else {
               userKey = "unavail"
          }

          // Update the labels
          nameLabel.text = userfName! + " " + userlName!
          studentKey.text = self.userKey
         
          addPinsAndZoom()
     }
     
     // ********************************
     // * Zoom to existing/current Pin *
     // ********************************
     func addPinsAndZoom(){
          if lat != nil && long != nil {
               
               dispatch_async(dispatch_get_main_queue()) {
                    self.mapView.removeAnnotations(self.mapView.annotations)
                    
                    let currLoc = CLLocationCoordinate2DMake(self.lat!, self.long!)
                    let mapPin = MKPointAnnotation()
                    mapPin.coordinate = currLoc
                    self.mapView.addAnnotation(mapPin)
                    
                    var zoomInView = MKMapCamera(lookingAtCenterCoordinate: currLoc, fromEyeCoordinate: currLoc, eyeAltitude: 10000.0)
                    self.mapView.setCamera(zoomInView, animated: true)
               }
          }
     }
}